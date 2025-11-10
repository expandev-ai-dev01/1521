/**
 * @summary
 * Creates a new media item (photo or video) with metadata and relationships.
 * Automatically sets status based on user role and validates file constraints.
 * 
 * @procedure spMediaCreate
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - POST /api/v1/internal/media
 * 
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 * 
 * @param {INT} idUser
 *   - Required: Yes
 *   - Description: User uploading the media
 * 
 * @param {INT} idMediaType
 *   - Required: Yes
 *   - Description: Media type identifier (1=Photo, 2=Video)
 * 
 * @param {NVARCHAR(100)} title
 *   - Required: Yes
 *   - Description: Media title
 * 
 * @param {NVARCHAR(500)} description
 *   - Required: No
 *   - Description: Media description
 * 
 * @param {DATE} captureDate
 *   - Required: Yes
 *   - Description: Date when media was captured
 * 
 * @param {NVARCHAR(100)} location
 *   - Required: No
 *   - Description: Location where media was captured
 * 
 * @param {NVARCHAR(100)} credits
 *   - Required: Yes
 *   - Description: Media credits/author
 * 
 * @param {NVARCHAR(20)} resolution
 *   - Required: Yes
 *   - Description: Media resolution
 * 
 * @param {NVARCHAR(500)} fileUrl
 *   - Required: Yes
 *   - Description: File URL
 * 
 * @param {NVARCHAR(500)} thumbnailUrl
 *   - Required: Yes
 *   - Description: Thumbnail URL
 * 
 * @param {VARCHAR(10)} fileFormat
 *   - Required: Yes
 *   - Description: File format
 * 
 * @param {INT} fileSize
 *   - Required: Yes
 *   - Description: File size in bytes
 * 
 * @param {INT} duration
 *   - Required: No
 *   - Description: Duration in seconds (videos only)
 * 
 * @param {NVARCHAR(300)} alternativeDescription
 *   - Required: Yes
 *   - Description: Alternative description for accessibility
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
 * @returns {INT} idMedia - Created media identifier
 * 
 * @testScenarios
 * - Create photo with all required fields
 * - Create video with duration
 * - Validation of file size limits
 * - Validation of capture date
 * - Association with categories and tags
 */
CREATE OR ALTER PROCEDURE [functional].[spMediaCreate]
  @idAccount INT,
  @idUser INT,
  @idMediaType INT,
  @title NVARCHAR(100),
  @description NVARCHAR(500) = NULL,
  @captureDate DATE,
  @location NVARCHAR(100) = NULL,
  @credits NVARCHAR(100),
  @resolution NVARCHAR(20),
  @fileUrl NVARCHAR(500),
  @thumbnailUrl NVARCHAR(500),
  @fileFormat VARCHAR(10),
  @fileSize INT,
  @duration INT = NULL,
  @alternativeDescription NVARCHAR(300),
  @categoriesJson NVARCHAR(MAX),
  @tagsJson NVARCHAR(MAX) = NULL,
  @teamsJson NVARCHAR(MAX) = NULL,
  @championshipsJson NVARCHAR(MAX) = NULL,
  @playersJson NVARCHAR(MAX) = NULL
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

  IF (@idMediaType IS NULL)
  BEGIN
    ;THROW 51000, 'idMediaTypeRequired', 1;
  END;

  IF (@title IS NULL OR LEN(@title) < 5)
  BEGIN
    ;THROW 51000, 'titleMinimumLength', 1;
  END;

  IF (@captureDate IS NULL)
  BEGIN
    ;THROW 51000, 'captureDateRequired', 1;
  END;

  IF (@captureDate > CAST(GETUTCDATE() AS DATE))
  BEGIN
    ;THROW 51000, 'captureDateCannotBeFuture', 1;
  END;

  IF (@credits IS NULL)
  BEGIN
    ;THROW 51000, 'creditsRequired', 1;
  END;

  IF (@fileUrl IS NULL)
  BEGIN
    ;THROW 51000, 'fileUrlRequired', 1;
  END;

  IF (@thumbnailUrl IS NULL)
  BEGIN
    ;THROW 51000, 'thumbnailUrlRequired', 1;
  END;

  IF (@alternativeDescription IS NULL OR LEN(@alternativeDescription) < 30)
  BEGIN
    ;THROW 51000, 'alternativeDescriptionMinimumLength', 1;
  END;

  IF (@categoriesJson IS NULL)
  BEGIN
    ;THROW 51000, 'categoriesRequired', 1;
  END;

  /**
   * @validation Media type existence
   * @throw {mediaTypeNotFound}
   */
  IF NOT EXISTS (
    SELECT 1
    FROM [functional].[mediaType] [medTyp]
    WHERE [medTyp].[idAccount] = @idAccount
      AND [medTyp].[idMediaType] = @idMediaType
      AND [medTyp].[deleted] = 0
  )
  BEGIN
    ;THROW 51000, 'mediaTypeNotFound', 1;
  END;

  BEGIN TRY
    BEGIN TRAN;

      DECLARE @idMedia INT;
      DECLARE @initialStatus INT = 0;

      /**
       * @rule {db-media-creation} Insert media record
       */
      INSERT INTO [functional].[media] (
        [idAccount],
        [idMediaType],
        [title],
        [description],
        [captureDate],
        [location],
        [credits],
        [resolution],
        [fileUrl],
        [thumbnailUrl],
        [fileFormat],
        [fileSize],
        [duration],
        [alternativeDescription],
        [status],
        [idUploader]
      )
      VALUES (
        @idAccount,
        @idMediaType,
        @title,
        @description,
        @captureDate,
        @location,
        @credits,
        @resolution,
        @fileUrl,
        @thumbnailUrl,
        @fileFormat,
        @fileSize,
        @duration,
        @alternativeDescription,
        @initialStatus,
        @idUser
      );

      SET @idMedia = SCOPE_IDENTITY();

      /**
       * @rule {db-media-categories} Associate categories
       */
      INSERT INTO [functional].[mediaCategory] ([idAccount], [idMedia], [idCategory])
      SELECT @idAccount, @idMedia, [value]
      FROM OPENJSON(@categoriesJson);

      /**
       * @rule {db-media-tags} Associate tags (create if needed)
       */
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

        INSERT INTO [functional].[mediaTag] ([idAccount], [idMedia], [idTag])
        SELECT @idAccount, @idMedia, [t].[idTag]
        FROM @tagNames [tn]
          JOIN [functional].[tag] [t] ON ([t].[idAccount] = @idAccount AND [t].[name] = [tn].[name])
        WHERE [t].[deleted] = 0;
      END;

      /**
       * @rule {db-media-teams} Associate teams
       */
      IF (@teamsJson IS NOT NULL)
      BEGIN
        INSERT INTO [functional].[mediaTeam] ([idAccount], [idMedia], [idTeam])
        SELECT @idAccount, @idMedia, [value]
        FROM OPENJSON(@teamsJson);
      END;

      /**
       * @rule {db-media-championships} Associate championships
       */
      IF (@championshipsJson IS NOT NULL)
      BEGIN
        INSERT INTO [functional].[mediaChampionship] ([idAccount], [idMedia], [idChampionship])
        SELECT @idAccount, @idMedia, [value]
        FROM OPENJSON(@championshipsJson);
      END;

      /**
       * @rule {db-media-players} Associate players
       */
      IF (@playersJson IS NOT NULL)
      BEGIN
        INSERT INTO [functional].[mediaPlayer] ([idAccount], [idMedia], [idPlayer])
        SELECT @idAccount, @idMedia, [value]
        FROM OPENJSON(@playersJson);
      END;

      /**
       * @output {MediaCreated, 1, 1}
       * @column {INT} idMedia - Created media identifier
       */
      SELECT @idMedia AS [idMedia];

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN;
    THROW;
  END CATCH;
END;
GO