/**
 * @summary
 * Lists news articles with filtering, pagination, and sorting capabilities.
 * Supports filtering by categories, teams, championships, players, dates, and search terms.
 * 
 * @procedure spNewsList
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - GET /api/v1/internal/news
 * 
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 * 
 * @param {NVARCHAR(MAX)} categoriesJson
 *   - Required: No
 *   - Description: JSON array of category IDs to filter
 * 
 * @param {NVARCHAR(MAX)} teamsJson
 *   - Required: No
 *   - Description: JSON array of team IDs to filter
 * 
 * @param {NVARCHAR(MAX)} championshipsJson
 *   - Required: No
 *   - Description: JSON array of championship IDs to filter
 * 
 * @param {NVARCHAR(MAX)} playersJson
 *   - Required: No
 *   - Description: JSON array of player IDs to filter
 * 
 * @param {DATE} startDate
 *   - Required: No
 *   - Description: Filter by publish date start
 * 
 * @param {DATE} endDate
 *   - Required: No
 *   - Description: Filter by publish date end
 * 
 * @param {NVARCHAR(100)} searchTerm
 *   - Required: No
 *   - Description: Search term for title, subtitle, and content
 * 
 * @param {INT} status
 *   - Required: No
 *   - Description: Filter by status (null = all published)
 * 
 * @param {NVARCHAR(20)} orderBy
 *   - Required: No
 *   - Description: Sort order (mais_recentes, mais_antigas, mais_lidas, relevancia)
 * 
 * @param {INT} pageSize
 *   - Required: No
 *   - Description: Items per page (default 20)
 * 
 * @param {INT} pageNumber
 *   - Required: No
 *   - Description: Page number (default 1)
 * 
 * @returns Multiple result sets with news list and pagination info
 * 
 * @testScenarios
 * - List all published news without filters
 * - Filter by single category
 * - Filter by multiple categories
 * - Filter by date range
 * - Search by text term
 * - Combine multiple filters
 * - Test pagination
 * - Test different sort orders
 */
CREATE OR ALTER PROCEDURE [functional].[spNewsList]
  @idAccount INT,
  @categoriesJson NVARCHAR(MAX) = NULL,
  @teamsJson NVARCHAR(MAX) = NULL,
  @championshipsJson NVARCHAR(MAX) = NULL,
  @playersJson NVARCHAR(MAX) = NULL,
  @startDate DATE = NULL,
  @endDate DATE = NULL,
  @searchTerm NVARCHAR(100) = NULL,
  @status INT = NULL,
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
   * @validation Search term minimum length
   * @throw {searchTermMinimumLength}
   */
  IF (@searchTerm IS NOT NULL AND LEN(@searchTerm) < 3)
  BEGIN
    ;THROW 51000, 'searchTermMinimumLength', 1;
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
   * @rule {db-news-filtering} Build filtered news query with all criteria
   */
  WITH [FilteredNews] AS (
    SELECT DISTINCT
      [nws].[idNews],
      [nws].[title],
      [nws].[subtitle],
      [nws].[publishDate],
      [nws].[featuredImage],
      [nws].[status],
      [nws].[featured],
      [nws].[viewCount],
      [nws].[readingTime],
      [nws].[sensitiveContent]
    FROM [functional].[news] [nws]
    WHERE [nws].[idAccount] = @idAccount
      AND [nws].[deleted] = 0
      AND (@status IS NULL OR [nws].[status] = @status)
      AND (@status IS NOT NULL OR [nws].[status] = 5)
      AND (@startDate IS NULL OR [nws].[publishDate] >= @startDate)
      AND (@endDate IS NULL OR [nws].[publishDate] <= @endDate)
      AND (
        @searchTerm IS NULL
        OR [nws].[title] LIKE '%' + @searchTerm + '%'
        OR [nws].[subtitle] LIKE '%' + @searchTerm + '%'
        OR [nws].[content] LIKE '%' + @searchTerm + '%'
      )
      AND (
        @categoriesJson IS NULL
        OR EXISTS (
          SELECT 1
          FROM [functional].[newsCategory] [nwsCat]
          WHERE [nwsCat].[idAccount] = @idAccount
            AND [nwsCat].[idNews] = [nws].[idNews]
            AND [nwsCat].[idCategory] IN (SELECT [value] FROM OPENJSON(@categoriesJson))
        )
      )
      AND (
        @teamsJson IS NULL
        OR EXISTS (
          SELECT 1
          FROM [functional].[newsTeam] [nwsTem]
          WHERE [nwsTem].[idAccount] = @idAccount
            AND [nwsTem].[idNews] = [nws].[idNews]
            AND [nwsTem].[idTeam] IN (SELECT [value] FROM OPENJSON(@teamsJson))
        )
      )
      AND (
        @championshipsJson IS NULL
        OR EXISTS (
          SELECT 1
          FROM [functional].[newsChampionship] [nwsChp]
          WHERE [nwsChp].[idAccount] = @idAccount
            AND [nwsChp].[idNews] = [nws].[idNews]
            AND [nwsChp].[idChampionship] IN (SELECT [value] FROM OPENJSON(@championshipsJson))
        )
      )
      AND (
        @playersJson IS NULL
        OR EXISTS (
          SELECT 1
          FROM [functional].[newsPlayer] [nwsPly]
          WHERE [nwsPly].[idAccount] = @idAccount
            AND [nwsPly].[idNews] = [nws].[idNews]
            AND [nwsPly].[idPlayer] IN (SELECT [value] FROM OPENJSON(@playersJson))
        )
      )
  )
  SELECT @totalCount = COUNT(*)
  FROM [FilteredNews];

  /**
   * @output {NewsList, n, n}
   * @column {INT} idNews - News identifier
   * @column {NVARCHAR} title - News title
   * @column {NVARCHAR} subtitle - News subtitle
   * @column {DATETIME2} publishDate - Publication date
   * @column {NVARCHAR} featuredImage - Featured image URL
   * @column {INT} status - News status
   * @column {BIT} featured - Featured flag
   * @column {INT} viewCount - View count
   * @column {INT} readingTime - Reading time in minutes
   * @column {BIT} sensitiveContent - Sensitive content flag
   */
  SELECT
    [fn].[idNews],
    [fn].[title],
    [fn].[subtitle],
    [fn].[publishDate],
    [fn].[featuredImage],
    [fn].[status],
    [fn].[featured],
    [fn].[viewCount],
    [fn].[readingTime],
    [fn].[sensitiveContent]
  FROM [FilteredNews] [fn]
  ORDER BY
    CASE WHEN @orderBy = 'mais_recentes' THEN [fn].[publishDate] END DESC,
    CASE WHEN @orderBy = 'mais_antigas' THEN [fn].[publishDate] END ASC,
    CASE WHEN @orderBy = 'mais_lidas' THEN [fn].[viewCount] END DESC,
    CASE WHEN @orderBy = 'relevancia' THEN [fn].[featured] END DESC,
    [fn].[publishDate] DESC
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
