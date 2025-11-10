/**
 * @summary
 * Retrieves complete news article details including all relationships and metadata.
 * Returns news data, categories, tags, teams, championships, players, and related news.
 * 
 * @procedure spNewsGet
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - GET /api/v1/internal/news/:id
 * 
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 * 
 * @param {INT} idNews
 *   - Required: Yes
 *   - Description: News identifier
 * 
 * @returns Multiple result sets with news details and relationships
 * 
 * @testScenarios
 * - Retrieve existing news with all relationships
 * - Retrieve news without optional relationships
 * - Attempt to retrieve non-existent news
 * - Attempt to retrieve deleted news
 * - Verify related news calculation
 */
CREATE OR ALTER PROCEDURE [functional].[spNewsGet]
  @idAccount INT,
  @idNews INT
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

  IF (@idNews IS NULL)
  BEGIN
    ;THROW 51000, 'idNewsRequired', 1;
  END;

  /**
   * @validation News existence
   * @throw {newsNotFound}
   */
  IF NOT EXISTS (
    SELECT 1
    FROM [functional].[news] [nws]
    WHERE [nws].[idAccount] = @idAccount
      AND [nws].[idNews] = @idNews
      AND [nws].[deleted] = 0
  )
  BEGIN
    ;THROW 51000, 'newsNotFound', 1;
  END;

  /**
   * @output {NewsDetails, 1, 1}
   * @column {INT} idNews - News identifier
   * @column {NVARCHAR} title - News title
   * @column {NVARCHAR} subtitle - News subtitle
   * @column {NVARCHAR} content - News content
   * @column {DATETIME2} publishDate - Publication date
   * @column {DATETIME2} updateDate - Last update date
   * @column {INT} idAuthor - Author identifier
   * @column {NVARCHAR} featuredImage - Featured image URL
   * @column {INT} status - News status
   * @column {BIT} featured - Featured flag
   * @column {NVARCHAR} externalSourceName - External source name
   * @column {NVARCHAR} externalSourceUrl - External source URL
   * @column {BIT} sensitiveContent - Sensitive content flag
   * @column {INT} viewCount - View count
   * @column {INT} readingTime - Reading time in minutes
   */
  SELECT
    [nws].[idNews],
    [nws].[title],
    [nws].[subtitle],
    [nws].[content],
    [nws].[publishDate],
    [nws].[updateDate],
    [nws].[idAuthor],
    [nws].[featuredImage],
    [nws].[status],
    [nws].[featured],
    [nws].[externalSourceName],
    [nws].[externalSourceUrl],
    [nws].[sensitiveContent],
    [nws].[viewCount],
    [nws].[readingTime]
  FROM [functional].[news] [nws]
  WHERE [nws].[idAccount] = @idAccount
    AND [nws].[idNews] = @idNews
    AND [nws].[deleted] = 0;

  /**
   * @output {NewsCategories, n, n}
   * @column {INT} idCategory - Category identifier
   * @column {NVARCHAR} name - Category name
   * @column {NVARCHAR} slug - Category slug
   */
  SELECT
    [cat].[idCategory],
    [cat].[name],
    [cat].[slug]
  FROM [functional].[newsCategory] [nwsCat]
    JOIN [functional].[category] [cat] ON ([cat].[idAccount] = [nwsCat].[idAccount] AND [cat].[idCategory] = [nwsCat].[idCategory])
  WHERE [nwsCat].[idAccount] = @idAccount
    AND [nwsCat].[idNews] = @idNews
    AND [cat].[deleted] = 0;

  /**
   * @output {NewsTags, n, n}
   * @column {INT} idTag - Tag identifier
   * @column {NVARCHAR} name - Tag name
   * @column {NVARCHAR} slug - Tag slug
   */
  SELECT
    [tag].[idTag],
    [tag].[name],
    [tag].[slug]
  FROM [functional].[newsTag] [nwsTag]
    JOIN [functional].[tag] [tag] ON ([tag].[idAccount] = [nwsTag].[idAccount] AND [tag].[idTag] = [nwsTag].[idTag])
  WHERE [nwsTag].[idAccount] = @idAccount
    AND [nwsTag].[idNews] = @idNews
    AND [tag].[deleted] = 0;

  /**
   * @output {NewsTeams, n, n}
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
  FROM [functional].[newsTeam] [nwsTem]
    JOIN [functional].[team] [tem] ON ([tem].[idAccount] = [nwsTem].[idAccount] AND [tem].[idTeam] = [nwsTem].[idTeam])
  WHERE [nwsTem].[idAccount] = @idAccount
    AND [nwsTem].[idNews] = @idNews
    AND [tem].[deleted] = 0;

  /**
   * @output {NewsChampionships, n, n}
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
  FROM [functional].[newsChampionship] [nwsChp]
    JOIN [functional].[championship] [chp] ON ([chp].[idAccount] = [nwsChp].[idAccount] AND [chp].[idChampionship] = [nwsChp].[idChampionship])
  WHERE [nwsChp].[idAccount] = @idAccount
    AND [nwsChp].[idNews] = @idNews
    AND [chp].[deleted] = 0;

  /**
   * @output {NewsPlayers, n, n}
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
  FROM [functional].[newsPlayer] [nwsPly]
    JOIN [functional].[player] [ply] ON ([ply].[idAccount] = [nwsPly].[idAccount] AND [ply].[idPlayer] = [nwsPly].[idPlayer])
  WHERE [nwsPly].[idAccount] = @idAccount
    AND [nwsPly].[idNews] = @idNews
    AND [ply].[deleted] = 0;

  /**
   * @output {SensitivityCriteria, n, n}
   * @column {INT} criteria - Sensitivity criteria code
   */
  SELECT
    [senCrt].[criteria]
  FROM [functional].[sensitivityCriteria] [senCrt]
  WHERE [senCrt].[idAccount] = @idAccount
    AND [senCrt].[idNews] = @idNews;

  /**
   * @output {ReviewComments, n, n}
   * @column {INT} idReviewComment - Comment identifier
   * @column {INT} idReviewer - Reviewer identifier
   * @column {NVARCHAR} comment - Review comment
   * @column {DATETIME2} dateCreated - Comment date
   */
  SELECT
    [rvwCmt].[idReviewComment],
    [rvwCmt].[idReviewer],
    [rvwCmt].[comment],
    [rvwCmt].[dateCreated]
  FROM [functional].[reviewComment] [rvwCmt]
  WHERE [rvwCmt].[idAccount] = @idAccount
    AND [rvwCmt].[idNews] = @idNews
    AND [rvwCmt].[deleted] = 0
  ORDER BY [rvwCmt].[dateCreated] DESC;

  /**
   * @output {StatusHistory, n, n}
   * @column {INT} previousStatus - Previous status
   * @column {INT} newStatus - New status
   * @column {INT} idUser - User who changed status
   * @column {DATETIME2} changeDate - Change date
   */
  SELECT
    [stsHst].[previousStatus],
    [stsHst].[newStatus],
    [stsHst].[idUser],
    [stsHst].[changeDate]
  FROM [functional].[statusHistory] [stsHst]
  WHERE [stsHst].[idAccount] = @idAccount
    AND [stsHst].[idNews] = @idNews
  ORDER BY [stsHst].[changeDate] DESC;

  /**
   * @rule {db-related-news} Calculate related news based on shared categories and tags
   * @output {RelatedNews, n, n}
   * @column {INT} idNews - Related news identifier
   * @column {NVARCHAR} title - Related news title
   * @column {NVARCHAR} featuredImage - Related news image
   * @column {DATETIME2} publishDate - Related news publish date
   */
  SELECT TOP 5
    [nws].[idNews],
    [nws].[title],
    [nws].[featuredImage],
    [nws].[publishDate]
  FROM [functional].[news] [nws]
  WHERE [nws].[idAccount] = @idAccount
    AND [nws].[idNews] <> @idNews
    AND [nws].[status] = 5
    AND [nws].[deleted] = 0
    AND [nws].[publishDate] >= DATEADD(DAY, -30, GETUTCDATE())
    AND (
      EXISTS (
        SELECT 1
        FROM [functional].[newsCategory] [nwsCat1]
          JOIN [functional].[newsCategory] [nwsCat2] ON ([nwsCat2].[idAccount] = [nwsCat1].[idAccount] AND [nwsCat2].[idCategory] = [nwsCat1].[idCategory])
        WHERE [nwsCat1].[idAccount] = @idAccount
          AND [nwsCat1].[idNews] = @idNews
          AND [nwsCat2].[idNews] = [nws].[idNews]
      )
      OR EXISTS (
        SELECT 1
        FROM [functional].[newsTag] [nwsTag1]
          JOIN [functional].[newsTag] [nwsTag2] ON ([nwsTag2].[idAccount] = [nwsTag1].[idAccount] AND [nwsTag2].[idTag] = [nwsTag1].[idTag])
        WHERE [nwsTag1].[idAccount] = @idAccount
          AND [nwsTag1].[idNews] = @idNews
          AND [nwsTag2].[idNews] = [nws].[idNews]
      )
    )
  ORDER BY [nws].[publishDate] DESC;
END;
GO
