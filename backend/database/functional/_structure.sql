/**
 * @schema functional
 * Business logic schema for Portal da Bola
 */
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'functional')
BEGIN
  EXEC('CREATE SCHEMA [functional]');
END;
GO

/**
 * @table mediaType Media type classification
 * @multitenancy true
 * @softDelete true
 * @alias medTyp
 */
CREATE TABLE [functional].[mediaType] (
  [idMediaType] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [name] NVARCHAR(50) NOT NULL,
  [code] VARCHAR(20) NOT NULL,
  [description] NVARCHAR(200) NULL,
  [active] BIT NOT NULL DEFAULT (1),
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @primaryKey pkMediaType
 * @keyType Object
 */
ALTER TABLE [functional].[mediaType]
ADD CONSTRAINT [pkMediaType] PRIMARY KEY CLUSTERED ([idMediaType]);
GO

/**
 * @index ixMediaType_Account Account isolation
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixMediaType_Account]
ON [functional].[mediaType]([idAccount])
WHERE [deleted] = 0;
GO

/**
 * @index uqMediaType_Account_Code Unique code per account
 * @type Search
 * @unique true
 */
CREATE UNIQUE NONCLUSTERED INDEX [uqMediaType_Account_Code]
ON [functional].[mediaType]([idAccount], [code])
WHERE [deleted] = 0;
GO

/**
 * @table media Multimedia content (photos and videos)
 * @multitenancy true
 * @softDelete true
 * @alias med
 */
CREATE TABLE [functional].[media] (
  [idMedia] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idMediaType] INTEGER NOT NULL,
  [title] NVARCHAR(100) NOT NULL,
  [description] NVARCHAR(500) NULL,
  [captureDate] DATE NOT NULL,
  [location] NVARCHAR(100) NULL,
  [credits] NVARCHAR(100) NOT NULL,
  [resolution] NVARCHAR(20) NOT NULL,
  [fileUrl] NVARCHAR(500) NOT NULL,
  [thumbnailUrl] NVARCHAR(500) NOT NULL,
  [fileFormat] VARCHAR(10) NOT NULL,
  [fileSize] INTEGER NOT NULL,
  [duration] INTEGER NULL,
  [alternativeDescription] NVARCHAR(300) NOT NULL,
  [viewCount] INTEGER NOT NULL DEFAULT (0),
  [shareCount] INTEGER NOT NULL DEFAULT (0),
  [status] INTEGER NOT NULL DEFAULT (0),
  [idUploader] INTEGER NOT NULL,
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @primaryKey pkMedia
 * @keyType Object
 */
ALTER TABLE [functional].[media]
ADD CONSTRAINT [pkMedia] PRIMARY KEY CLUSTERED ([idMedia]);
GO

/**
 * @foreignKey fkMedia_MediaType Media type reference
 * @target functional.mediaType
 */
ALTER TABLE [functional].[media]
ADD CONSTRAINT [fkMedia_MediaType] FOREIGN KEY ([idMediaType])
REFERENCES [functional].[mediaType]([idMediaType]);
GO

/**
 * @check chkMedia_Status Status validation
 * @enum {0} pendente
 * @enum {1} aprovado
 * @enum {2} rejeitado
 * @enum {3} publicado
 */
ALTER TABLE [functional].[media]
ADD CONSTRAINT [chkMedia_Status] CHECK ([status] BETWEEN 0 AND 3);
GO

/**
 * @index ixMedia_Account Account isolation
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixMedia_Account]
ON [functional].[media]([idAccount])
WHERE [deleted] = 0;
GO

/**
 * @index ixMedia_Account_MediaType Type filtering
 * @type Search
 */
CREATE NONCLUSTERED INDEX [ixMedia_Account_MediaType]
ON [functional].[media]([idAccount], [idMediaType])
INCLUDE ([title], [captureDate], [status])
WHERE [deleted] = 0;
GO

/**
 * @index ixMedia_Account_Status Status filtering
 * @type Search
 */
CREATE NONCLUSTERED INDEX [ixMedia_Account_Status]
ON [functional].[media]([idAccount], [status])
INCLUDE ([title], [thumbnailUrl], [captureDate])
WHERE [deleted] = 0;
GO

/**
 * @index ixMedia_Account_CaptureDate Date ordering
 * @type Performance
 */
CREATE NONCLUSTERED INDEX [ixMedia_Account_CaptureDate]
ON [functional].[media]([idAccount], [captureDate] DESC)
INCLUDE ([title], [thumbnailUrl], [idMediaType])
WHERE [deleted] = 0;
GO

/**
 * @table mediaTag Media-Tag relationship
 * @multitenancy true
 * @softDelete false
 * @alias medTag
 */
CREATE TABLE [functional].[mediaTag] (
  [idAccount] INTEGER NOT NULL,
  [idMedia] INTEGER NOT NULL,
  [idTag] INTEGER NOT NULL,
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE())
);
GO

/**
 * @primaryKey pkMediaTag
 * @keyType Relationship
 */
ALTER TABLE [functional].[mediaTag]
ADD CONSTRAINT [pkMediaTag] PRIMARY KEY CLUSTERED ([idAccount], [idMedia], [idTag]);
GO

/**
 * @foreignKey fkMediaTag_Media Media reference
 * @target functional.media
 */
ALTER TABLE [functional].[mediaTag]
ADD CONSTRAINT [fkMediaTag_Media] FOREIGN KEY ([idMedia])
REFERENCES [functional].[media]([idMedia]);
GO

/**
 * @foreignKey fkMediaTag_Tag Tag reference
 * @target functional.tag
 */
ALTER TABLE [functional].[mediaTag]
ADD CONSTRAINT [fkMediaTag_Tag] FOREIGN KEY ([idTag])
REFERENCES [functional].[tag]([idTag]);
GO

/**
 * @index ixMediaTag_Account_Media Media tags lookup
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixMediaTag_Account_Media]
ON [functional].[mediaTag]([idAccount], [idMedia]);
GO

/**
 * @index ixMediaTag_Account_Tag Tag media lookup
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixMediaTag_Account_Tag]
ON [functional].[mediaTag]([idAccount], [idTag]);
GO

/**
 * @table mediaCategory Media-Category relationship
 * @multitenancy true
 * @softDelete false
 * @alias medCat
 */
CREATE TABLE [functional].[mediaCategory] (
  [idAccount] INTEGER NOT NULL,
  [idMedia] INTEGER NOT NULL,
  [idCategory] INTEGER NOT NULL,
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE())
);
GO

/**
 * @primaryKey pkMediaCategory
 * @keyType Relationship
 */
ALTER TABLE [functional].[mediaCategory]
ADD CONSTRAINT [pkMediaCategory] PRIMARY KEY CLUSTERED ([idAccount], [idMedia], [idCategory]);
GO

/**
 * @foreignKey fkMediaCategory_Media Media reference
 * @target functional.media
 */
ALTER TABLE [functional].[mediaCategory]
ADD CONSTRAINT [fkMediaCategory_Media] FOREIGN KEY ([idMedia])
REFERENCES [functional].[media]([idMedia]);
GO

/**
 * @foreignKey fkMediaCategory_Category Category reference
 * @target functional.category
 */
ALTER TABLE [functional].[mediaCategory]
ADD CONSTRAINT [fkMediaCategory_Category] FOREIGN KEY ([idCategory])
REFERENCES [functional].[category]([idCategory]);
GO

/**
 * @table mediaTeam Media-Team relationship
 * @multitenancy true
 * @softDelete false
 * @alias medTem
 */
CREATE TABLE [functional].[mediaTeam] (
  [idAccount] INTEGER NOT NULL,
  [idMedia] INTEGER NOT NULL,
  [idTeam] INTEGER NOT NULL,
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE())
);
GO

/**
 * @primaryKey pkMediaTeam
 * @keyType Relationship
 */
ALTER TABLE [functional].[mediaTeam]
ADD CONSTRAINT [pkMediaTeam] PRIMARY KEY CLUSTERED ([idAccount], [idMedia], [idTeam]);
GO

/**
 * @foreignKey fkMediaTeam_Media Media reference
 * @target functional.media
 */
ALTER TABLE [functional].[mediaTeam]
ADD CONSTRAINT [fkMediaTeam_Media] FOREIGN KEY ([idMedia])
REFERENCES [functional].[media]([idMedia]);
GO

/**
 * @foreignKey fkMediaTeam_Team Team reference
 * @target functional.team
 */
ALTER TABLE [functional].[mediaTeam]
ADD CONSTRAINT [fkMediaTeam_Team] FOREIGN KEY ([idTeam])
REFERENCES [functional].[team]([idTeam]);
GO

/**
 * @table mediaChampionship Media-Championship relationship
 * @multitenancy true
 * @softDelete false
 * @alias medChp
 */
CREATE TABLE [functional].[mediaChampionship] (
  [idAccount] INTEGER NOT NULL,
  [idMedia] INTEGER NOT NULL,
  [idChampionship] INTEGER NOT NULL,
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE())
);
GO

/**
 * @primaryKey pkMediaChampionship
 * @keyType Relationship
 */
ALTER TABLE [functional].[mediaChampionship]
ADD CONSTRAINT [pkMediaChampionship] PRIMARY KEY CLUSTERED ([idAccount], [idMedia], [idChampionship]);
GO

/**
 * @foreignKey fkMediaChampionship_Media Media reference
 * @target functional.media
 */
ALTER TABLE [functional].[mediaChampionship]
ADD CONSTRAINT [fkMediaChampionship_Media] FOREIGN KEY ([idMedia])
REFERENCES [functional].[media]([idMedia]);
GO

/**
 * @foreignKey fkMediaChampionship_Championship Championship reference
 * @target functional.championship
 */
ALTER TABLE [functional].[mediaChampionship]
ADD CONSTRAINT [fkMediaChampionship_Championship] FOREIGN KEY ([idChampionship])
REFERENCES [functional].[championship]([idChampionship]);
GO

/**
 * @table mediaPlayer Media-Player relationship
 * @multitenancy true
 * @softDelete false
 * @alias medPly
 */
CREATE TABLE [functional].[mediaPlayer] (
  [idAccount] INTEGER NOT NULL,
  [idMedia] INTEGER NOT NULL,
  [idPlayer] INTEGER NOT NULL,
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE())
);
GO

/**
 * @primaryKey pkMediaPlayer
 * @keyType Relationship
 */
ALTER TABLE [functional].[mediaPlayer]
ADD CONSTRAINT [pkMediaPlayer] PRIMARY KEY CLUSTERED ([idAccount], [idMedia], [idPlayer]);
GO

/**
 * @foreignKey fkMediaPlayer_Media Media reference
 * @target functional.media
 */
ALTER TABLE [functional].[mediaPlayer]
ADD CONSTRAINT [fkMediaPlayer_Media] FOREIGN KEY ([idMedia])
REFERENCES [functional].[media]([idMedia]);
GO

/**
 * @foreignKey fkMediaPlayer_Player Player reference
 * @target functional.player
 */
ALTER TABLE [functional].[mediaPlayer]
ADD CONSTRAINT [fkMediaPlayer_Player] FOREIGN KEY ([idPlayer])
REFERENCES [functional].[player]([idPlayer]);
GO

/**
 * @table mediaView Media view tracking
 * @multitenancy true
 * @softDelete false
 * @alias medVw
 */
CREATE TABLE [functional].[mediaView] (
  [idMediaView] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idMedia] INTEGER NOT NULL,
  [sessionId] NVARCHAR(100) NOT NULL,
  [ipAddress] NVARCHAR(45) NOT NULL,
  [userAgent] NVARCHAR(500) NOT NULL,
  [viewDate] DATETIME2 NOT NULL DEFAULT (GETUTCDATE())
);
GO

/**
 * @primaryKey pkMediaView
 * @keyType Object
 */
ALTER TABLE [functional].[mediaView]
ADD CONSTRAINT [pkMediaView] PRIMARY KEY CLUSTERED ([idMediaView]);
GO

/**
 * @foreignKey fkMediaView_Media Media reference
 * @target functional.media
 */
ALTER TABLE [functional].[mediaView]
ADD CONSTRAINT [fkMediaView_Media] FOREIGN KEY ([idMedia])
REFERENCES [functional].[media]([idMedia]);
GO

/**
 * @index ixMediaView_Account_Media_Session Session view lookup
 * @type Performance
 */
CREATE NONCLUSTERED INDEX [ixMediaView_Account_Media_Session]
ON [functional].[mediaView]([idAccount], [idMedia], [sessionId])
INCLUDE ([viewDate]);
GO

/**
 * @table mediaShare Media share tracking
 * @multitenancy true
 * @softDelete false
 * @alias medShr
 */
CREATE TABLE [functional].[mediaShare] (
  [idMediaShare] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idMedia] INTEGER NOT NULL,
  [platform] VARCHAR(50) NOT NULL,
  [sessionId] NVARCHAR(100) NOT NULL,
  [shareDate] DATETIME2 NOT NULL DEFAULT (GETUTCDATE())
);
GO

/**
 * @primaryKey pkMediaShare
 * @keyType Object
 */
ALTER TABLE [functional].[mediaShare]
ADD CONSTRAINT [pkMediaShare] PRIMARY KEY CLUSTERED ([idMediaShare]);
GO

/**
 * @foreignKey fkMediaShare_Media Media reference
 * @target functional.media
 */
ALTER TABLE [functional].[mediaShare]
ADD CONSTRAINT [fkMediaShare_Media] FOREIGN KEY ([idMedia])
REFERENCES [functional].[media]([idMedia]);
GO

/**
 * @index ixMediaShare_Account_Media Media shares lookup
 * @type Performance
 */
CREATE NONCLUSTERED INDEX [ixMediaShare_Account_Media]
ON [functional].[mediaShare]([idAccount], [idMedia])
INCLUDE ([platform], [shareDate]);
GO

/**
 * @table mediaComment Media comments
 * @multitenancy true
 * @softDelete true
 * @alias medCmt
 */
CREATE TABLE [functional].[mediaComment] (
  [idMediaComment] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idMedia] INTEGER NOT NULL,
  [idUser] INTEGER NOT NULL,
  [comment] NVARCHAR(300) NOT NULL,
  [idParentComment] INTEGER NULL,
  [reportCount] INTEGER NOT NULL DEFAULT (0),
  [status] INTEGER NOT NULL DEFAULT (0),
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @primaryKey pkMediaComment
 * @keyType Object
 */
ALTER TABLE [functional].[mediaComment]
ADD CONSTRAINT [pkMediaComment] PRIMARY KEY CLUSTERED ([idMediaComment]);
GO

/**
 * @foreignKey fkMediaComment_Media Media reference
 * @target functional.media
 */
ALTER TABLE [functional].[mediaComment]
ADD CONSTRAINT [fkMediaComment_Media] FOREIGN KEY ([idMedia])
REFERENCES [functional].[media]([idMedia]);
GO

/**
 * @foreignKey fkMediaComment_Parent Parent comment reference
 * @target functional.mediaComment
 */
ALTER TABLE [functional].[mediaComment]
ADD CONSTRAINT [fkMediaComment_Parent] FOREIGN KEY ([idParentComment])
REFERENCES [functional].[mediaComment]([idMediaComment]);
GO

/**
 * @check chkMediaComment_Status Status validation
 * @enum {0} publicado
 * @enum {1} em_moderacao
 * @enum {2} rejeitado
 */
ALTER TABLE [functional].[mediaComment]
ADD CONSTRAINT [chkMediaComment_Status] CHECK ([status] BETWEEN 0 AND 2);
GO

/**
 * @index ixMediaComment_Account_Media Media comments lookup
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixMediaComment_Account_Media]
ON [functional].[mediaComment]([idAccount], [idMedia])
WHERE [deleted] = 0;
GO

/**
 * @table thematicGallery Thematic galleries
 * @multitenancy true
 * @softDelete true
 * @alias thmGal
 */
CREATE TABLE [functional].[thematicGallery] (
  [idThematicGallery] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [title] NVARCHAR(100) NOT NULL,
  [slug] NVARCHAR(110) NOT NULL,
  [description] NVARCHAR(500) NOT NULL,
  [coverImageUrl] NVARCHAR(500) NOT NULL,
  [featured] BIT NOT NULL DEFAULT (0),
  [featuredOrder] INTEGER NULL,
  [status] INTEGER NOT NULL DEFAULT (0),
  [idCreator] INTEGER NOT NULL,
  [viewCount] INTEGER NOT NULL DEFAULT (0),
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @primaryKey pkThematicGallery
 * @keyType Object
 */
ALTER TABLE [functional].[thematicGallery]
ADD CONSTRAINT [pkThematicGallery] PRIMARY KEY CLUSTERED ([idThematicGallery]);
GO

/**
 * @check chkThematicGallery_Status Status validation
 * @enum {0} rascunho
 * @enum {1} publicado
 * @enum {2} arquivado
 */
ALTER TABLE [functional].[thematicGallery]
ADD CONSTRAINT [chkThematicGallery_Status] CHECK ([status] BETWEEN 0 AND 2);
GO

/**
 * @index ixThematicGallery_Account Account isolation
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixThematicGallery_Account]
ON [functional].[thematicGallery]([idAccount])
WHERE [deleted] = 0;
GO

/**
 * @index ixThematicGallery_Account_Featured Featured galleries
 * @type Search
 */
CREATE NONCLUSTERED INDEX [ixThematicGallery_Account_Featured]
ON [functional].[thematicGallery]([idAccount], [featured], [featuredOrder])
INCLUDE ([title], [coverImageUrl])
WHERE [deleted] = 0 AND [featured] = 1;
GO

/**
 * @table thematicGalleryMedia Gallery-Media relationship
 * @multitenancy true
 * @softDelete false
 * @alias thmGalMed
 */
CREATE TABLE [functional].[thematicGalleryMedia] (
  [idAccount] INTEGER NOT NULL,
  [idThematicGallery] INTEGER NOT NULL,
  [idMedia] INTEGER NOT NULL,
  [displayOrder] INTEGER NOT NULL DEFAULT (999),
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE())
);
GO

/**
 * @primaryKey pkThematicGalleryMedia
 * @keyType Relationship
 */
ALTER TABLE [functional].[thematicGalleryMedia]
ADD CONSTRAINT [pkThematicGalleryMedia] PRIMARY KEY CLUSTERED ([idAccount], [idThematicGallery], [idMedia]);
GO

/**
 * @foreignKey fkThematicGalleryMedia_Gallery Gallery reference
 * @target functional.thematicGallery
 */
ALTER TABLE [functional].[thematicGalleryMedia]
ADD CONSTRAINT [fkThematicGalleryMedia_Gallery] FOREIGN KEY ([idThematicGallery])
REFERENCES [functional].[thematicGallery]([idThematicGallery]);
GO

/**
 * @foreignKey fkThematicGalleryMedia_Media Media reference
 * @target functional.media
 */
ALTER TABLE [functional].[thematicGalleryMedia]
ADD CONSTRAINT [fkThematicGalleryMedia_Media] FOREIGN KEY ([idMedia])
REFERENCES [functional].[media]([idMedia]);
GO

/**
 * @index ixThematicGalleryMedia_Account_Gallery Gallery media lookup
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixThematicGalleryMedia_Account_Gallery]
ON [functional].[thematicGalleryMedia]([idAccount], [idThematicGallery])
INCLUDE ([displayOrder]);
GO