/**
 * @summary
 * Updates an existing news article with new data and relationships.
 * Maintains status history and updates modification timestamp.
 * 
 * @procedure spNewsUpdate
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - PUT /api/v1/internal/news/:id
 * 
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 * 
 * @param {INT} idUser
 *   - Required: Yes
 *   - Description: User updating the news
 * 
 * @param {INT} idNews
 *   - Required: Yes
 *   - Description: News identifier to update
 * 
 * @param {NVARCHAR(150)} title
 *   - Required: Yes
 *   - Description: News title
 * 
 * @param {NVARCHAR(250)} subtitle
 *   - Required: No
 *   - Description: News subtitle
 * 
 * @param {NVARCHAR(MAX)} content
 *   - Required: Yes
 *   - Description: News content with HTML formatting
 * 
 * @param {NVARCHAR(500)} featuredImage
 *   - Required: Yes
 *   - Description: Featured image URL
 * 
 * @param {BIT} featured
 *   - Required: Yes
 *   - Description: Featured flag
 * 
 * @param {NVARCHAR(100)} externalSourceName
 *   - Required: No
 *   - Description: External source name
 * 
 * @param {NVARCHAR(255)} externalSourceUrl
 *   - Required: No
 *   - Description: External source URL
 * 
 * @param {BIT} sensitiveContent
 *   - Required: Yes
 *   - Description: Sensitive content flag
 * 
 * @param {NVARCHAR(MAX)} categoriesJson
 *   - Required: Yes
 *   - Description: JSON array of category IDs
 * 
 * @param {NVARCHAR(MAX)} tagsJson
 *   - Required: No
 *   - Description: JSON array of tag names
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
 * @param {NVARCHAR(MAX)} sensitivityCriteriaJson
 *   - Required: No
 *   - Description: JSON array of sensitivity criteria (0-6)
 * 
 * @testScenarios
 * - Update news with all fields
 * - Update news with partial fields
 * - Update relationships (add/remove)
 * - Validation of constraints
 * - Attempt to update non-existent news
 * - Attempt to update deleted news
 */
CREATE OR ALTER PROCEDURE [functional].[spNewsUpdate]
  @idAccount INT,
  @idUser INT,
  @idNews INT,
  @title NVARCHAR(150),
  @subtitle NVARCHAR(250) = NULL,
  @content NVARCHAR(MAX),
  @featuredImage NVARCHAR(500),
  @featured BIT = 0,
  @externalSourceName NVARCHAR(100) = NULL,
  @externalSourceUrl NVARCHAR(255) = NULL,
  @sensitiveContent BIT = 0,
  @categoriesJson NVARCHAR(MAX),
  @tagsJson NVARCHAR(MAX) = NULL,
  @teamsJson NVARCHAR(MAX) = NULL,
  @championshipsJson NVARCHAR(MAX) = NULL,
  @playersJson NVARCHAR(MAX) = NULL,
  @sensitivityCriteriaJson NVARCHAR(MAX) = NULL
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

  IF (@idUser IS NULL)
  BEGIN
    ;THROW 51000, 'idUserRequired', 1;
  END;

  IF (@idNews IS NULL)
  BEGIN
    ;THROW 51000, 'idNewsRequired', 1;
  END;

  IF (@title IS NULL OR LEN(@title) < 10)
  BEGIN
    ;THROW 51000, 'titleMinimumLength', 1;
  END;

  IF (LEN(@title) > 150)
  BEGIN
    ;THROW 51000, 'titleMaximumLength', 1;
  END;

  IF (@content IS NULL OR LEN(@content) < 500)
  BEGIN
    ;THROW 51000, 'contentMinimumLength', 1;
  END;

  IF (@featuredImage IS NULL)
  BEGIN
    ;THROW 51000, 'featuredImageRequired', 1;
  END;

  IF (@categoriesJson IS NULL)
  BEGIN
    ;THROW 51000, 'categoriesRequired', 1;
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
   * @validation Sensitive content criteria
   * @throw {sensitivityCriteriaRequired}
   */
  IF (@sensitiveContent = 1 AND @sensitivityCriteriaJson IS NULL)
  BEGIN
    ;THROW 51000, 'sensitivityCriteriaRequired', 1;
  END;

  /**
   * @validation External source completeness
   * @throw {externalSourceNameRequired}
   */
  IF (@externalSourceUrl IS NOT NULL AND @externalSourceName IS NULL)
  BEGIN
    ;THROW 51000, 'externalSourceNameRequired', 1;
  END;

  BEGIN TRY
    BEGIN TRAN;

      DECLARE @readingTime INT;
      DECLARE @wordCount INT;

      /**
       * @rule {fn-news-reading-time} Recalculate reading time
       */
      SET @wordCount = (LEN(@content) - LEN(REPLACE(@content, ' ', '')) + 1);
      SET @readingTime = CEILING(@wordCount / 200.0);

      /**
       * @rule {db-news-update} Update news record
       */
      UPDATE [functional].[news]
      SET
        [title] = @title,
        [subtitle] = @subtitle,
        [content] = @content,
        [featuredImage] = @featuredImage,
        [featured] = @featured,
        [externalSourceName] = @externalSourceName,
        [externalSourceUrl] = @externalSourceUrl,
        [sensitiveContent] = @sensitiveContent,
        [readingTime] = @readingTime,
        [updateDate] = GETUTCDATE(),
        [dateModified] = GETUTCDATE()
      WHERE [idAccount] = @idAccount
        AND [idNews] = @idNews;

      /**
       * @rule {db-news-categories-update} Update categories (MERGE pattern)
       */
      DELETE FROM [functional].[newsCategory]
      WHERE [idAccount] = @idAccount
        AND [idNews] = @idNews;

      INSERT INTO [functional].[newsCategory] ([idAccount], [idNews], [idCategory])
      SELECT @idAccount, @idNews, [value]
      FROM OPENJSON(@categoriesJson);

      /**
       * @rule {db-news-tags-update} Update tags
       */
      DELETE FROM [functional].[newsTag]
      WHERE [idAccount] = @idAccount
        AND [idNews] = @idNews;

      IF (@tagsJson IS NOT NULL)
      BEGIN
        DECLARE @tagNames TABLE ([name] NVARCHAR(30));
        
        INSERT INTO @tagNames ([name])
        SELECT [value]
        FROM OPENJSON(@tagsJson);

        INSERT INTO [functional].[tag] ([idAccount], [name], [slug])
        SELECT @idAccount, [tn].[name], LOWER(REPLACE([tn].[name], ' ', '-'))
        FROM @tagNames [tn]
        WHERE NOT EXISTS (
          SELECT 1
          FROM [functional].[tag] [t]
          WHERE [t].[idAccount] = @idAccount
            AND [t].[name] = [tn].[name]
            AND [t].[deleted] = 0
        );

        INSERT INTO [functional].[newsTag] ([idAccount], [idNews], [idTag])
        SELECT @idAccount, @idNews, [t].[idTag]
        FROM @tagNames [tn]
          JOIN [functional].[tag] [t] ON ([t].[idAccount] = @idAccount AND [t].[name] = [tn].[name])
        WHERE [t].[deleted] = 0;
      END;

      /**
       * @rule {db-news-teams-update} Update teams
       */
      DELETE FROM [functional].[newsTeam]
      WHERE [idAccount] = @idAccount
        AND [idNews] = @idNews;

      IF (@teamsJson IS NOT NULL)
      BEGIN
        INSERT INTO [functional].[newsTeam] ([idAccount], [idNews], [idTeam])
        SELECT @idAccount, @idNews, [value]
        FROM OPENJSON(@teamsJson);
      END;

      /**
       * @rule {db-news-championships-update} Update championships
       */
      DELETE FROM [functional].[newsChampionship]
      WHERE [idAccount] = @idAccount
        AND [idNews] = @idNews;

      IF (@championshipsJson IS NOT NULL)
      BEGIN
        INSERT INTO [functional].[newsChampionship] ([idAccount], [idNews], [idChampionship])
        SELECT @idAccount, @idNews, [value]
        FROM OPENJSON(@championshipsJson);
      END;

      /**
       * @rule {db-news-players-update} Update players
       */
      DELETE FROM [functional].[newsPlayer]
      WHERE [idAccount] = @idAccount
        AND [idNews] = @idNews;

      IF (@playersJson IS NOT NULL)
      BEGIN
        INSERT INTO [functional].[newsPlayer] ([idAccount], [idNews], [idPlayer])
        SELECT @idAccount, @idNews, [value]
        FROM OPENJSON(@playersJson);
      END;

      /**
       * @rule {db-sensitivity-criteria-update} Update sensitivity criteria
       */
      DELETE FROM [functional].[sensitivityCriteria]
      WHERE [idAccount] = @idAccount
        AND [idNews] = @idNews;

      IF (@sensitivityCriteriaJson IS NOT NULL)
      BEGIN
        INSERT INTO [functional].[sensitivityCriteria] ([idAccount], [idNews], [criteria])
        SELECT @idAccount, @idNews, [value]
        FROM OPENJSON(@sensitivityCriteriaJson);
      END;

      /**
       * @output {NewsUpdated, 1, 1}
       * @column {INT} idNews - Updated news identifier
       */
      SELECT @idNews AS [idNews];

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN;
    THROW;
  END CATCH;
END;
GO
