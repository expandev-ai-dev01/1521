/**
 * @summary
 * Registers a media view and increments view counter if unique within 24 hours.
 * Implements session-based view tracking to prevent duplicate counting.
 * 
 * @procedure spMediaViewRegister
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - POST /api/v1/internal/media/:id/view
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
 * @param {NVARCHAR(100)} sessionId
 *   - Required: Yes
 *   - Description: User session identifier
 * 
 * @param {NVARCHAR(45)} ipAddress
 *   - Required: Yes
 *   - Description: User IP address
 * 
 * @param {NVARCHAR(500)} userAgent
 *   - Required: Yes
 *   - Description: User agent string
 * 
 * @returns View registration result
 * 
 * @testScenarios
 * - Register first view for session
 * - Attempt duplicate view within 24 hours
 * - Register view after 24 hours
 * - Verify view counter increment
 */
CREATE OR ALTER PROCEDURE [functional].[spMediaViewRegister]
  @idAccount INT,
  @idMedia INT,
  @sessionId NVARCHAR(100),
  @ipAddress NVARCHAR(45),
  @userAgent NVARCHAR(500)
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

  IF (@sessionId IS NULL)
  BEGIN
    ;THROW 51000, 'sessionIdRequired', 1;
  END;

  IF (@ipAddress IS NULL)
  BEGIN
    ;THROW 51000, 'ipAddressRequired', 1;
  END;

  IF (@userAgent IS NULL)
  BEGIN
    ;THROW 51000, 'userAgentRequired', 1;
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

  DECLARE @shouldIncrement BIT = 0;
  DECLARE @lastViewDate DATETIME2;

  /**
   * @rule {fn-view-uniqueness} Check if view should be counted (24-hour window)
   */
  SELECT TOP 1 @lastViewDate = [medVw].[viewDate]
  FROM [functional].[mediaView] [medVw]
  WHERE [medVw].[idAccount] = @idAccount
    AND [medVw].[idMedia] = @idMedia
    AND [medVw].[sessionId] = @sessionId
  ORDER BY [medVw].[viewDate] DESC;

  IF (@lastViewDate IS NULL OR DATEDIFF(HOUR, @lastViewDate, GETUTCDATE()) >= 24)
  BEGIN
    SET @shouldIncrement = 1;
  END;

  BEGIN TRY
    BEGIN TRAN;

      /**
       * @rule {db-view-registration} Register view
       */
      INSERT INTO [functional].[mediaView] (
        [idAccount],
        [idMedia],
        [sessionId],
        [ipAddress],
        [userAgent]
      )
      VALUES (
        @idAccount,
        @idMedia,
        @sessionId,
        @ipAddress,
        @userAgent
      );

      /**
       * @rule {db-view-counter-increment} Increment view counter if unique
       */
      IF (@shouldIncrement = 1)
      BEGIN
        UPDATE [functional].[media]
        SET [viewCount] = [viewCount] + 1
        WHERE [idAccount] = @idAccount
          AND [idMedia] = @idMedia;
      END;

      /**
       * @output {ViewRegistered, 1, 1}
       * @column {BIT} incremented - Whether view counter was incremented
       * @column {INT} viewCount - Current view count
       */
      SELECT
        @shouldIncrement AS [incremented],
        [med].[viewCount]
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