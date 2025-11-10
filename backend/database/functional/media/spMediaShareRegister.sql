/**
 * @summary
 * Registers a media share and increments share counter.
 * Tracks sharing platform for analytics.
 * 
 * @procedure spMediaShareRegister
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - POST /api/v1/internal/media/:id/share
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
 * @param {VARCHAR(50)} platform
 *   - Required: Yes
 *   - Description: Sharing platform (facebook, twitter, whatsapp, etc.)
 * 
 * @param {NVARCHAR(100)} sessionId
 *   - Required: Yes
 *   - Description: User session identifier
 * 
 * @returns Share registration result
 * 
 * @testScenarios
 * - Register share on different platforms
 * - Verify share counter increment
 * - Attempt to share non-existent media
 */
CREATE OR ALTER PROCEDURE [functional].[spMediaShareRegister]
  @idAccount INT,
  @idMedia INT,
  @platform VARCHAR(50),
  @sessionId NVARCHAR(100)
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

  IF (@platform IS NULL)
  BEGIN
    ;THROW 51000, 'platformRequired', 1;
  END;

  IF (@sessionId IS NULL)
  BEGIN
    ;THROW 51000, 'sessionIdRequired', 1;
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
      AND [med].[status] = 3
  )
  BEGIN
    ;THROW 51000, 'mediaNotFound', 1;
  END;

  BEGIN TRY
    BEGIN TRAN;

      /**
       * @rule {db-share-registration} Register share
       */
      INSERT INTO [functional].[mediaShare] (
        [idAccount],
        [idMedia],
        [platform],
        [sessionId]
      )
      VALUES (
        @idAccount,
        @idMedia,
        @platform,
        @sessionId
      );

      /**
       * @rule {db-share-counter-increment} Increment share counter
       */
      UPDATE [functional].[media]
      SET [shareCount] = [shareCount] + 1
      WHERE [idAccount] = @idAccount
        AND [idMedia] = @idMedia;

      /**
       * @output {ShareRegistered, 1, 1}
       * @column {INT} shareCount - Current share count
       */
      SELECT
        [med].[shareCount]
      FROM [functional].[media] [med]
      WHERE [med].[idAccount] = @idAccount
        AND [med].[idMedia] = @idMedia;

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN;
    THROW;
  END CATCH;
END;
GO