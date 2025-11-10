/**
 * @summary
 * Lists media items with filtering, pagination, and sorting capabilities.
 * Supports filtering by type, categories, teams, championships, players, dates, and tags.
 * 
 * @procedure spMediaList
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - GET /api/v1/internal/media
 * 
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 * 
 * @param {INT} idMediaType
 *   - Required: No
 *   - Description: Filter by media type
 * 
 * @param {NVARCHAR(MAX)} categoriesJson
 *   - Required: No
 *   - Description: JSON array of category IDs
 * 
 * @param {NVARCHAR(MAX)} tagsJson
 *   - Required: No
 *   - Description: JSON array of tag IDs
 * 
 * @param {NVARCHAR(MAX)} teamsJson
 *   - Required: No
 *   - Description: JSON array of team IDs
 * 
 * @param {NVARCHAR(MAX)} championshipsJson
 *   - Required: No
 *   - Description: JSON array of championship IDs
 * 
 * @param {NVARCHAR(MAX)} playersJson
 *   - Required: No
 *   - Description: JSON array of player IDs
 * 
 * @param {DATE} startDate
 *   - Required: No
 *   - Description: Filter by capture date start
 * 
 * @param {DATE} endDate
 *   - Required: No
 *   - Description: Filter by capture date end
 * 
 * @param {NVARCHAR(20)} orderBy
 *   - Required: No
 *   - Description: Sort order (mais_recentes, mais_antigas, mais_visualizados, mais_compartilhados)
 * 
 * @param {INT} pageSize
 *   - Required: No
 *   - Description: Items per page (default 20)
 * 
 * @param {INT} pageNumber
 *   - Required: No
 *   - Description: Page number (default 1)
 * 
 * @returns Multiple result sets with media list and pagination info
 * 
 * @testScenarios
 * - List all published media
 * - Filter by media type
 * - Filter by categories
 * - Filter by date range
 * - Test pagination
 * - Test different sort orders
 */
CREATE OR ALTER PROCEDURE [functional].[spMediaList]
  @idAccount INT,
  @idMediaType INT = NULL,
  @categoriesJson NVARCHAR(MAX) = NULL,
  @tagsJson NVARCHAR(MAX) = NULL,
  @teamsJson NVARCHAR(MAX) = NULL,
  @championshipsJson NVARCHAR(MAX) = NULL,
  @playersJson NVARCHAR(MAX) = NULL,
  @startDate DATE = NULL,
  @endDate DATE = NULL,
  @orderBy NVARCHAR(20) = 'mais_recentes',
  @pageSize INT = 20,
  @pageNumber INT = 1
AS
BEGIN
  SET NOCOUNT ON;

  /**
   * @validation Required parameters
   * @throw {parameterRequired}
   */
  IF (@idAccount IS NULL)
  BEGIN
    ;THROW 51000, 'idAccountRequired', 1;
  END;

  /**
   * @validation Date range
   * @throw {invalidDateRange}
   */
  IF (@startDate IS NOT NULL AND @endDate IS NOT NULL AND @endDate < @startDate)
  BEGIN
    ;THROW 51000, 'invalidDateRange', 1;
  END;

  DECLARE @offset INT = (@pageNumber - 1) * @pageSize;
  DECLARE @totalCount INT;

  /**
   * @rule {db-media-filtering} Build filtered media query
   */
  WITH [FilteredMedia] AS (
    SELECT DISTINCT
      [med].[idMedia],
      [med].[idMediaType],
      [med].[title],
      [med].[captureDate],
      [med].[thumbnailUrl],
      [med].[viewCount],
      [med].[shareCount],
      [med].[duration]
    FROM [functional].[media] [med]
    WHERE [med].[idAccount] = @idAccount
      AND [med].[deleted] = 0
      AND [med].[status] = 3
      AND (@idMediaType IS NULL OR [med].[idMediaType] = @idMediaType)
      AND (@startDate IS NULL OR [med].[captureDate] >= @startDate)
      AND (@endDate IS NULL OR [med].[captureDate] <= @endDate)
      AND (
        @categoriesJson IS NULL
        OR EXISTS (
          SELECT 1
          FROM [functional].[mediaCategory] [medCat]
          WHERE [medCat].[idAccount] = @idAccount
            AND [medCat].[idMedia] = [med].[idMedia]
            AND [medCat].[idCategory] IN (SELECT [value] FROM OPENJSON(@categoriesJson))
        )
      )
      AND (
        @tagsJson IS NULL
        OR EXISTS (
          SELECT 1
          FROM [functional].[mediaTag] [medTag]
          WHERE [medTag].[idAccount] = @idAccount
            AND [medTag].[idMedia] = [med].[idMedia]
            AND [medTag].[idTag] IN (SELECT [value] FROM OPENJSON(@tagsJson))
        )
      )
      AND (
        @teamsJson IS NULL
        OR EXISTS (
          SELECT 1
          FROM [functional].[mediaTeam] [medTem]
          WHERE [medTem].[idAccount] = @idAccount
            AND [medTem].[idMedia] = [med].[idMedia]
            AND [medTem].[idTeam] IN (SELECT [value] FROM OPENJSON(@teamsJson))
        )
      )
      AND (
        @championshipsJson IS NULL
        OR EXISTS (
          SELECT 1
          FROM [functional].[mediaChampionship] [medChp]
          WHERE [medChp].[idAccount] = @idAccount
            AND [medChp].[idMedia] = [med].[idMedia]
            AND [medChp].[idChampionship] IN (SELECT [value] FROM OPENJSON(@championshipsJson))
        )
      )
      AND (
        @playersJson IS NULL
        OR EXISTS (
          SELECT 1
          FROM [functional].[mediaPlayer] [medPly]
          WHERE [medPly].[idAccount] = @idAccount
            AND [medPly].[idMedia] = [med].[idMedia]
            AND [medPly].[idPlayer] IN (SELECT [value] FROM OPENJSON(@playersJson))
        )
      )
  )
  SELECT @totalCount = COUNT(*)
  FROM [FilteredMedia];

  /**
   * @output {MediaList, n, n}
   * @column {INT} idMedia - Media identifier
   * @column {INT} idMediaType - Media type identifier
   * @column {NVARCHAR} title - Media title
   * @column {DATE} captureDate - Capture date
   * @column {NVARCHAR} thumbnailUrl - Thumbnail URL
   * @column {INT} viewCount - View count
   * @column {INT} shareCount - Share count
   * @column {INT} duration - Duration in seconds (videos only)
   */
  SELECT
    [fm].[idMedia],
    [fm].[idMediaType],
    [fm].[title],
    [fm].[captureDate],
    [fm].[thumbnailUrl],
    [fm].[viewCount],
    [fm].[shareCount],
    [fm].[duration]
  FROM [FilteredMedia] [fm]
  ORDER BY
    CASE WHEN @orderBy = 'mais_recentes' THEN [fm].[captureDate] END DESC,
    CASE WHEN @orderBy = 'mais_antigas' THEN [fm].[captureDate] END ASC,
    CASE WHEN @orderBy = 'mais_visualizados' THEN [fm].[viewCount] END DESC,
    CASE WHEN @orderBy = 'mais_compartilhados' THEN [fm].[shareCount] END DESC,
    [fm].[captureDate] DESC
  OFFSET @offset ROWS
  FETCH NEXT @pageSize ROWS ONLY;

  /**
   * @output {PaginationInfo, 1, 1}
   * @column {INT} totalCount - Total number of records
   * @column {INT} pageSize - Items per page
   * @column {INT} pageNumber - Current page number
   * @column {INT} totalPages - Total number of pages
   */
  SELECT
    @totalCount AS [totalCount],
    @pageSize AS [pageSize],
    @pageNumber AS [pageNumber],
    CEILING(CAST(@totalCount AS FLOAT) / @pageSize) AS [totalPages];
END;
GO