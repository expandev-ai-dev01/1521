/**
 * @summary
 * Soft deletes a news article by setting the deleted flag.
 * Maintains referential integrity and audit trail.
 * 
 * @procedure spNewsDelete
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - DELETE /api/v1/internal/news/:id
 * 
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 * 
 * @param {INT} idNews
 *   - Required: Yes
 *   - Description: News identifier to delete
 * 
 * @testScenarios
 * - Delete existing news
 * - Attempt to delete non-existent news
 * - Attempt to delete already deleted news
 * - Verify soft delete (record still exists)
 */
CREATE OR ALTER PROCEDURE [functional].[spNewsDelete]
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
   * @rule {db-soft-delete} Soft delete news record
   */
  UPDATE [functional].[news]
  SET
    [deleted] = 1,
    [dateModified] = GETUTCDATE()
  WHERE [idAccount] = @idAccount
    AND [idNews] = @idNews;

  /**
   * @output {NewsDeleted, 1, 1}
   * @column {INT} idNews - Deleted news identifier
   */
  SELECT @idNews AS [idNews];
END;
GO
