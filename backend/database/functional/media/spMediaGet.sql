/**
 * @summary
 * Retrieves complete media details including all relationships and metadata.
 * Returns media data, categories, tags, teams, championships, and players.
 * 
 * @procedure spMediaGet
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - GET /api/v1/internal/media/:id
 * 
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 * 
 * @param {INT} idMedia
 *   - Required: Yes
 *   - Description: Media identifier
 * 
 * @returns Multiple result sets with media details and relationships
 * 
 * @testScenarios
 * - Retrieve existing media with all relationships
 * - Retrieve media without optional relationships
 * - Attempt to retrieve non-existent media
 * - Attempt to retrieve deleted media
 */
CREATE OR ALTER PROCEDURE [functional].[spMediaGet]
  @idAccount INT,
  @idMedia INT
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

  IF (@idMedia IS NULL)
  BEGIN
    ;THROW 51000, 'idMediaRequired', 1;
  END;

  /**
   * @validation Media existence
   * @throw {mediaNotFound}
   */
  IF NOT EXISTS (
    SELECT 1
    FROM [functional].[media] [med]
    WHERE [med].[idAccount] = @idAccount
      AND [med].[idMedia] = @idMedia
      AND [med].[deleted] = 0
  )
  BEGIN
    ;THROW 51000, 'mediaNotFound', 1;
  END;

  /**
   * @output {MediaDetails, 1, 1}
   * @column {INT} idMedia - Media identifier
   * @column {INT} idMediaType - Media type identifier
   * @column {NVARCHAR} title - Media title
   * @column {NVARCHAR} description - Media description
   * @column {DATE} captureDate - Capture date
   * @column {NVARCHAR} location - Location
   * @column {NVARCHAR} credits - Credits
   * @column {NVARCHAR} resolution - Resolution
   * @column {NVARCHAR} fileUrl - File URL
   * @column {NVARCHAR} thumbnailUrl - Thumbnail URL
   * @column {VARCHAR} fileFormat - File format
   * @column {INT} fileSize - File size in bytes
   * @column {INT} duration - Duration in seconds
   * @column {NVARCHAR} alternativeDescription - Alternative description
   * @column {INT} viewCount - View count
   * @column {INT} shareCount - Share count
   * @column {INT} status - Media status
   */
  SELECT
    [med].[idMedia],
    [med].[idMediaType],
    [med].[title],
    [med].[description],
    [med].[captureDate],
    [med].[location],
    [med].[credits],
    [med].[resolution],
    [med].[fileUrl],
    [med].[thumbnailUrl],
    [med].[fileFormat],
    [med].[fileSize],
    [med].[duration],
    [med].[alternativeDescription],
    [med].[viewCount],
    [med].[shareCount],
    [med].[status]
  FROM [functional].[media] [med]
  WHERE [med].[idAccount] = @idAccount
    AND [med].[idMedia] = @idMedia
    AND [med].[deleted] = 0;

  /**
   * @output {MediaCategories, n, n}
   * @column {INT} idCategory - Category identifier
   * @column {NVARCHAR} name - Category name
   * @column {NVARCHAR} slug - Category slug
   */
  SELECT
    [cat].[idCategory],
    [cat].[name],
    [cat].[slug]
  FROM [functional].[mediaCategory] [medCat]
    JOIN [functional].[category] [cat] ON ([cat].[idAccount] = [medCat].[idAccount] AND [cat].[idCategory] = [medCat].[idCategory])
  WHERE [medCat].[idAccount] = @idAccount
    AND [medCat].[idMedia] = @idMedia
    AND [cat].[deleted] = 0;

  /**
   * @output {MediaTags, n, n}
   * @column {INT} idTag - Tag identifier
   * @column {NVARCHAR} name - Tag name
   * @column {NVARCHAR} slug - Tag slug
   */
  SELECT
    [tag].[idTag],
    [tag].[name],
    [tag].[slug]
  FROM [functional].[mediaTag] [medTag]
    JOIN [functional].[tag] [tag] ON ([tag].[idAccount] = [medTag].[idAccount] AND [tag].[idTag] = [medTag].[idTag])
  WHERE [medTag].[idAccount] = @idAccount
    AND [medTag].[idMedia] = @idMedia
    AND [tag].[deleted] = 0;

  /**
   * @output {MediaTeams, n, n}
   * @column {INT} idTeam - Team identifier
   * @column {NVARCHAR} name - Team name
   * @column {NVARCHAR} slug - Team slug
   * @column {NVARCHAR} image - Team image URL
   */
  SELECT
    [tem].[idTeam],
    [tem].[name],
    [tem].[slug],
    [tem].[image]
  FROM [functional].[mediaTeam] [medTem]
    JOIN [functional].[team] [tem] ON ([tem].[idAccount] = [medTem].[idAccount] AND [tem].[idTeam] = [medTem].[idTeam])
  WHERE [medTem].[idAccount] = @idAccount
    AND [medTem].[idMedia] = @idMedia
    AND [tem].[deleted] = 0;

  /**
   * @output {MediaChampionships, n, n}
   * @column {INT} idChampionship - Championship identifier
   * @column {NVARCHAR} name - Championship name
   * @column {NVARCHAR} slug - Championship slug
   * @column {NVARCHAR} image - Championship image URL
   */
  SELECT
    [chp].[idChampionship],
    [chp].[name],
    [chp].[slug],
    [chp].[image]
  FROM [functional].[mediaChampionship] [medChp]
    JOIN [functional].[championship] [chp] ON ([chp].[idAccount] = [medChp].[idAccount] AND [chp].[idChampionship] = [medChp].[idChampionship])
  WHERE [medChp].[idAccount] = @idAccount
    AND [medChp].[idMedia] = @idMedia
    AND [chp].[deleted] = 0;

  /**
   * @output {MediaPlayers, n, n}
   * @column {INT} idPlayer - Player identifier
   * @column {NVARCHAR} name - Player name
   * @column {NVARCHAR} slug - Player slug
   * @column {NVARCHAR} image - Player image URL
   */
  SELECT
    [ply].[idPlayer],
    [ply].[name],
    [ply].[slug],
    [ply].[image]
  FROM [functional].[mediaPlayer] [medPly]
    JOIN [functional].[player] [ply] ON ([ply].[idAccount] = [medPly].[idAccount] AND [ply].[idPlayer] = [medPly].[idPlayer])
  WHERE [medPly].[idAccount] = @idAccount
    AND [medPly].[idMedia] = @idMedia
    AND [ply].[deleted] = 0;
END;
GO