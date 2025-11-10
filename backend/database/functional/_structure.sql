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
 * @table news News articles with comprehensive metadata
 * @multitenancy true
 * @softDelete true
 * @alias nws
 */
CREATE TABLE [functional].[news] (
  [idNews] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [title] NVARCHAR(150) NOT NULL,
  [subtitle] NVARCHAR(250) NULL,
  [content] NVARCHAR(MAX) NOT NULL,
  [publishDate] DATETIME2 NULL,
  [updateDate] DATETIME2 NULL,
  [idAuthor] INTEGER NOT NULL,
  [featuredImage] NVARCHAR(500) NOT NULL,
  [status] INTEGER NOT NULL DEFAULT (0),
  [featured] BIT NOT NULL DEFAULT (0),
  [externalSourceName] NVARCHAR(100) NULL,
  [externalSourceUrl] NVARCHAR(255) NULL,
  [sensitiveContent] BIT NOT NULL DEFAULT (0),
  [viewCount] INTEGER NOT NULL DEFAULT (0),
  [readingTime] INTEGER NOT NULL,
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @primaryKey pkNews
 * @keyType Object
 */
ALTER TABLE [functional].[news]
ADD CONSTRAINT [pkNews] PRIMARY KEY CLUSTERED ([idNews]);
GO

/**
 * @check chkNews_Status Status validation
 * @enum {0} rascunho
 * @enum {1} em_revisao
 * @enum {2} em_revisao_sensivel
 * @enum {3} aprovado_parcial
 * @enum {4} aprovado
 * @enum {5} publicado
 * @enum {6} arquivado
 * @enum {7} rejeitado
 */
ALTER TABLE [functional].[news]
ADD CONSTRAINT [chkNews_Status] CHECK ([status] BETWEEN 0 AND 7);
GO

/**
 * @index ixNews_Account Account isolation
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixNews_Account]
ON [functional].[news]([idAccount])
WHERE [deleted] = 0;
GO

/**
 * @index ixNews_Account_Status Status filtering
 * @type Search
 */
CREATE NONCLUSTERED INDEX [ixNews_Account_Status]
ON [functional].[news]([idAccount], [status])
INCLUDE ([title], [publishDate], [featured])
WHERE [deleted] = 0;
GO

/**
 * @index ixNews_Account_PublishDate Date ordering
 * @type Performance
 */
CREATE NONCLUSTERED INDEX [ixNews_Account_PublishDate]
ON [functional].[news]([idAccount], [publishDate] DESC)
INCLUDE ([title], [subtitle], [featuredImage], [status])
WHERE [deleted] = 0;
GO

/**
 * @index ixNews_Account_Featured Featured news
 * @type Search
 */
CREATE NONCLUSTERED INDEX [ixNews_Account_Featured]
ON [functional].[news]([idAccount], [featured])
INCLUDE ([title], [publishDate])
WHERE [deleted] = 0 AND [featured] = 1;
GO

/**
 * @table category News categories
 * @multitenancy true
 * @softDelete true
 * @alias cat
 */
CREATE TABLE [functional].[category] (
  [idCategory] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [name] NVARCHAR(50) NOT NULL,
  [description] NVARCHAR(200) NULL,
  [slug] NVARCHAR(60) NOT NULL,
  [icon] NVARCHAR(100) NULL,
  [color] NVARCHAR(7) NULL,
  [displayOrder] INTEGER NOT NULL DEFAULT (999),
  [active] BIT NOT NULL DEFAULT (1),
  [idParent] INTEGER NULL,
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @primaryKey pkCategory
 * @keyType Object
 */
ALTER TABLE [functional].[category]
ADD CONSTRAINT [pkCategory] PRIMARY KEY CLUSTERED ([idCategory]);
GO

/**
 * @foreignKey fkCategory_Parent Parent category reference
 * @target functional.category
 */
ALTER TABLE [functional].[category]
ADD CONSTRAINT [fkCategory_Parent] FOREIGN KEY ([idParent])
REFERENCES [functional].[category]([idCategory]);
GO

/**
 * @index ixCategory_Account Account isolation
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixCategory_Account]
ON [functional].[category]([idAccount])
WHERE [deleted] = 0;
GO

/**
 * @index ixCategory_Account_Active Active categories
 * @type Search
 */
CREATE NONCLUSTERED INDEX [ixCategory_Account_Active]
ON [functional].[category]([idAccount], [active])
INCLUDE ([name], [slug], [displayOrder])
WHERE [deleted] = 0;
GO

/**
 * @index uqCategory_Account_Name Unique category name per account
 * @type Search
 * @unique true
 */
CREATE UNIQUE NONCLUSTERED INDEX [uqCategory_Account_Name]
ON [functional].[category]([idAccount], [name])
WHERE [deleted] = 0;
GO

/**
 * @index uqCategory_Account_Slug Unique slug per account
 * @type Search
 * @unique true
 */
CREATE UNIQUE NONCLUSTERED INDEX [uqCategory_Account_Slug]
ON [functional].[category]([idAccount], [slug])
WHERE [deleted] = 0;
GO

/**
 * @table newsCategory News-Category relationship
 * @multitenancy true
 * @softDelete false
 * @alias nwsCat
 */
CREATE TABLE [functional].[newsCategory] (
  [idAccount] INTEGER NOT NULL,
  [idNews] INTEGER NOT NULL,
  [idCategory] INTEGER NOT NULL,
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE())
);
GO

/**
 * @primaryKey pkNewsCategory
 * @keyType Relationship
 */
ALTER TABLE [functional].[newsCategory]
ADD CONSTRAINT [pkNewsCategory] PRIMARY KEY CLUSTERED ([idAccount], [idNews], [idCategory]);
GO

/**
 * @foreignKey fkNewsCategory_News News reference
 * @target functional.news
 */
ALTER TABLE [functional].[newsCategory]
ADD CONSTRAINT [fkNewsCategory_News] FOREIGN KEY ([idNews])
REFERENCES [functional].[news]([idNews]);
GO

/**
 * @foreignKey fkNewsCategory_Category Category reference
 * @target functional.category
 */
ALTER TABLE [functional].[newsCategory]
ADD CONSTRAINT [fkNewsCategory_Category] FOREIGN KEY ([idCategory])
REFERENCES [functional].[category]([idCategory]);
GO

/**
 * @index ixNewsCategory_Account_News News categories lookup
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixNewsCategory_Account_News]
ON [functional].[newsCategory]([idAccount], [idNews]);
GO

/**
 * @index ixNewsCategory_Account_Category Category news lookup
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixNewsCategory_Account_Category]
ON [functional].[newsCategory]([idAccount], [idCategory]);
GO

/**
 * @table tag Content tags
 * @multitenancy true
 * @softDelete true
 * @alias tag
 */
CREATE TABLE [functional].[tag] (
  [idTag] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [name] NVARCHAR(30) NOT NULL,
  [slug] NVARCHAR(35) NOT NULL,
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @primaryKey pkTag
 * @keyType Object
 */
ALTER TABLE [functional].[tag]
ADD CONSTRAINT [pkTag] PRIMARY KEY CLUSTERED ([idTag]);
GO

/**
 * @index ixTag_Account Account isolation
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixTag_Account]
ON [functional].[tag]([idAccount])
WHERE [deleted] = 0;
GO

/**
 * @index uqTag_Account_Name Unique tag name per account
 * @type Search
 * @unique true
 */
CREATE UNIQUE NONCLUSTERED INDEX [uqTag_Account_Name]
ON [functional].[tag]([idAccount], [name])
WHERE [deleted] = 0;
GO

/**
 * @table newsTag News-Tag relationship
 * @multitenancy true
 * @softDelete false
 * @alias nwsTag
 */
CREATE TABLE [functional].[newsTag] (
  [idAccount] INTEGER NOT NULL,
  [idNews] INTEGER NOT NULL,
  [idTag] INTEGER NOT NULL,
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE())
);
GO

/**
 * @primaryKey pkNewsTag
 * @keyType Relationship
 */
ALTER TABLE [functional].[newsTag]
ADD CONSTRAINT [pkNewsTag] PRIMARY KEY CLUSTERED ([idAccount], [idNews], [idTag]);
GO

/**
 * @foreignKey fkNewsTag_News News reference
 * @target functional.news
 */
ALTER TABLE [functional].[newsTag]
ADD CONSTRAINT [fkNewsTag_News] FOREIGN KEY ([idNews])
REFERENCES [functional].[news]([idNews]);
GO

/**
 * @foreignKey fkNewsTag_Tag Tag reference
 * @target functional.tag
 */
ALTER TABLE [functional].[newsTag]
ADD CONSTRAINT [fkNewsTag_Tag] FOREIGN KEY ([idTag])
REFERENCES [functional].[tag]([idTag]);
GO

/**
 * @table team Football teams
 * @multitenancy true
 * @softDelete true
 * @alias tem
 */
CREATE TABLE [functional].[team] (
  [idTeam] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [slug] NVARCHAR(110) NOT NULL,
  [description] NVARCHAR(500) NULL,
  [image] NVARCHAR(500) NULL,
  [country] NVARCHAR(100) NOT NULL,
  [foundationDate] DATE NULL,
  [stadium] NVARCHAR(100) NULL,
  [colors] NVARCHAR(200) NULL,
  [active] BIT NOT NULL DEFAULT (1),
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @primaryKey pkTeam
 * @keyType Object
 */
ALTER TABLE [functional].[team]
ADD CONSTRAINT [pkTeam] PRIMARY KEY CLUSTERED ([idTeam]);
GO

/**
 * @index ixTeam_Account Account isolation
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixTeam_Account]
ON [functional].[team]([idAccount])
WHERE [deleted] = 0;
GO

/**
 * @index uqTeam_Account_Name Unique team name per account
 * @type Search
 * @unique true
 */
CREATE UNIQUE NONCLUSTERED INDEX [uqTeam_Account_Name]
ON [functional].[team]([idAccount], [name])
WHERE [deleted] = 0;
GO

/**
 * @table championship Football championships
 * @multitenancy true
 * @softDelete true
 * @alias chp
 */
CREATE TABLE [functional].[championship] (
  [idChampionship] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [slug] NVARCHAR(110) NOT NULL,
  [description] NVARCHAR(500) NULL,
  [image] NVARCHAR(500) NULL,
  [country] NVARCHAR(100) NOT NULL,
  [season] NVARCHAR(20) NULL,
  [startDate] DATE NULL,
  [endDate] DATE NULL,
  [organizer] NVARCHAR(100) NULL,
  [active] BIT NOT NULL DEFAULT (1),
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @primaryKey pkChampionship
 * @keyType Object
 */
ALTER TABLE [functional].[championship]
ADD CONSTRAINT [pkChampionship] PRIMARY KEY CLUSTERED ([idChampionship]);
GO

/**
 * @index ixChampionship_Account Account isolation
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixChampionship_Account]
ON [functional].[championship]([idAccount])
WHERE [deleted] = 0;
GO

/**
 * @table player Football players
 * @multitenancy true
 * @softDelete true
 * @alias ply
 */
CREATE TABLE [functional].[player] (
  [idPlayer] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [slug] NVARCHAR(110) NOT NULL,
  [description] NVARCHAR(500) NULL,
  [image] NVARCHAR(500) NULL,
  [country] NVARCHAR(100) NOT NULL,
  [birthDate] DATE NULL,
  [position] NVARCHAR(50) NULL,
  [height] NUMERIC(4, 2) NULL,
  [active] BIT NOT NULL DEFAULT (1),
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @primaryKey pkPlayer
 * @keyType Object
 */
ALTER TABLE [functional].[player]
ADD CONSTRAINT [pkPlayer] PRIMARY KEY CLUSTERED ([idPlayer]);
GO

/**
 * @index ixPlayer_Account Account isolation
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixPlayer_Account]
ON [functional].[player]([idAccount])
WHERE [deleted] = 0;
GO

/**
 * @table newsTeam News-Team relationship
 * @multitenancy true
 * @softDelete false
 * @alias nwsTem
 */
CREATE TABLE [functional].[newsTeam] (
  [idAccount] INTEGER NOT NULL,
  [idNews] INTEGER NOT NULL,
  [idTeam] INTEGER NOT NULL,
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE())
);
GO

/**
 * @primaryKey pkNewsTeam
 * @keyType Relationship
 */
ALTER TABLE [functional].[newsTeam]
ADD CONSTRAINT [pkNewsTeam] PRIMARY KEY CLUSTERED ([idAccount], [idNews], [idTeam]);
GO

/**
 * @foreignKey fkNewsTeam_News News reference
 * @target functional.news
 */
ALTER TABLE [functional].[newsTeam]
ADD CONSTRAINT [fkNewsTeam_News] FOREIGN KEY ([idNews])
REFERENCES [functional].[news]([idNews]);
GO

/**
 * @foreignKey fkNewsTeam_Team Team reference
 * @target functional.team
 */
ALTER TABLE [functional].[newsTeam]
ADD CONSTRAINT [fkNewsTeam_Team] FOREIGN KEY ([idTeam])
REFERENCES [functional].[team]([idTeam]);
GO

/**
 * @table newsChampionship News-Championship relationship
 * @multitenancy true
 * @softDelete false
 * @alias nwsChp
 */
CREATE TABLE [functional].[newsChampionship] (
  [idAccount] INTEGER NOT NULL,
  [idNews] INTEGER NOT NULL,
  [idChampionship] INTEGER NOT NULL,
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE())
);
GO

/**
 * @primaryKey pkNewsChampionship
 * @keyType Relationship
 */
ALTER TABLE [functional].[newsChampionship]
ADD CONSTRAINT [pkNewsChampionship] PRIMARY KEY CLUSTERED ([idAccount], [idNews], [idChampionship]);
GO

/**
 * @foreignKey fkNewsChampionship_News News reference
 * @target functional.news
 */
ALTER TABLE [functional].[newsChampionship]
ADD CONSTRAINT [fkNewsChampionship_News] FOREIGN KEY ([idNews])
REFERENCES [functional].[news]([idNews]);
GO

/**
 * @foreignKey fkNewsChampionship_Championship Championship reference
 * @target functional.championship
 */
ALTER TABLE [functional].[newsChampionship]
ADD CONSTRAINT [fkNewsChampionship_Championship] FOREIGN KEY ([idChampionship])
REFERENCES [functional].[championship]([idChampionship]);
GO

/**
 * @table newsPlayer News-Player relationship
 * @multitenancy true
 * @softDelete false
 * @alias nwsPly
 */
CREATE TABLE [functional].[newsPlayer] (
  [idAccount] INTEGER NOT NULL,
  [idNews] INTEGER NOT NULL,
  [idPlayer] INTEGER NOT NULL,
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE())
);
GO

/**
 * @primaryKey pkNewsPlayer
 * @keyType Relationship
 */
ALTER TABLE [functional].[newsPlayer]
ADD CONSTRAINT [pkNewsPlayer] PRIMARY KEY CLUSTERED ([idAccount], [idNews], [idPlayer]);
GO

/**
 * @foreignKey fkNewsPlayer_News News reference
 * @target functional.news
 */
ALTER TABLE [functional].[newsPlayer]
ADD CONSTRAINT [fkNewsPlayer_News] FOREIGN KEY ([idNews])
REFERENCES [functional].[news]([idNews]);
GO

/**
 * @foreignKey fkNewsPlayer_Player Player reference
 * @target functional.player
 */
ALTER TABLE [functional].[newsPlayer]
ADD CONSTRAINT [fkNewsPlayer_Player] FOREIGN KEY ([idPlayer])
REFERENCES [functional].[player]([idPlayer]);
GO

/**
 * @table teamChampionship Team-Championship relationship
 * @multitenancy true
 * @softDelete false
 * @alias temChp
 */
CREATE TABLE [functional].[teamChampionship] (
  [idAccount] INTEGER NOT NULL,
  [idTeam] INTEGER NOT NULL,
  [idChampionship] INTEGER NOT NULL,
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE())
);
GO

/**
 * @primaryKey pkTeamChampionship
 * @keyType Relationship
 */
ALTER TABLE [functional].[teamChampionship]
ADD CONSTRAINT [pkTeamChampionship] PRIMARY KEY CLUSTERED ([idAccount], [idTeam], [idChampionship]);
GO

/**
 * @foreignKey fkTeamChampionship_Team Team reference
 * @target functional.team
 */
ALTER TABLE [functional].[teamChampionship]
ADD CONSTRAINT [fkTeamChampionship_Team] FOREIGN KEY ([idTeam])
REFERENCES [functional].[team]([idTeam]);
GO

/**
 * @foreignKey fkTeamChampionship_Championship Championship reference
 * @target functional.championship
 */
ALTER TABLE [functional].[teamChampionship]
ADD CONSTRAINT [fkTeamChampionship_Championship] FOREIGN KEY ([idChampionship])
REFERENCES [functional].[championship]([idChampionship]);
GO

/**
 * @table playerTeam Player-Team relationship (current)
 * @multitenancy true
 * @softDelete false
 * @alias plyTem
 */
CREATE TABLE [functional].[playerTeam] (
  [idAccount] INTEGER NOT NULL,
  [idPlayer] INTEGER NOT NULL,
  [idTeam] INTEGER NOT NULL,
  [current] BIT NOT NULL DEFAULT (1),
  [startDate] DATE NULL,
  [endDate] DATE NULL,
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE())
);
GO

/**
 * @primaryKey pkPlayerTeam
 * @keyType Relationship
 */
ALTER TABLE [functional].[playerTeam]
ADD CONSTRAINT [pkPlayerTeam] PRIMARY KEY CLUSTERED ([idAccount], [idPlayer], [idTeam], [current]);
GO

/**
 * @foreignKey fkPlayerTeam_Player Player reference
 * @target functional.player
 */
ALTER TABLE [functional].[playerTeam]
ADD CONSTRAINT [fkPlayerTeam_Player] FOREIGN KEY ([idPlayer])
REFERENCES [functional].[player]([idPlayer]);
GO

/**
 * @foreignKey fkPlayerTeam_Team Team reference
 * @target functional.team
 */
ALTER TABLE [functional].[playerTeam]
ADD CONSTRAINT [fkPlayerTeam_Team] FOREIGN KEY ([idTeam])
REFERENCES [functional].[team]([idTeam]);
GO

/**
 * @table sensitivityCriteria Sensitivity criteria for content review
 * @multitenancy true
 * @softDelete false
 * @alias senCrt
 */
CREATE TABLE [functional].[sensitivityCriteria] (
  [idAccount] INTEGER NOT NULL,
  [idNews] INTEGER NOT NULL,
  [criteria] INTEGER NOT NULL,
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE())
);
GO

/**
 * @primaryKey pkSensitivityCriteria
 * @keyType Relationship
 */
ALTER TABLE [functional].[sensitivityCriteria]
ADD CONSTRAINT [pkSensitivityCriteria] PRIMARY KEY CLUSTERED ([idAccount], [idNews], [criteria]);
GO

/**
 * @foreignKey fkSensitivityCriteria_News News reference
 * @target functional.news
 */
ALTER TABLE [functional].[sensitivityCriteria]
ADD CONSTRAINT [fkSensitivityCriteria_News] FOREIGN KEY ([idNews])
REFERENCES [functional].[news]([idNews]);
GO

/**
 * @check chkSensitivityCriteria_Criteria Criteria validation
 * @enum {0} violencia
 * @enum {1} politica
 * @enum {2} religiao
 * @enum {3} discriminacao
 * @enum {4} doping
 * @enum {5} corrupcao
 * @enum {6} outro
 */
ALTER TABLE [functional].[sensitivityCriteria]
ADD CONSTRAINT [chkSensitivityCriteria_Criteria] CHECK ([criteria] BETWEEN 0 AND 6);
GO

/**
 * @table newsReviewer News reviewers tracking
 * @multitenancy true
 * @softDelete false
 * @alias nwsRvw
 */
CREATE TABLE [functional].[newsReviewer] (
  [idAccount] INTEGER NOT NULL,
  [idNews] INTEGER NOT NULL,
  [idReviewer] INTEGER NOT NULL,
  [reviewDate] DATETIME2 NOT NULL DEFAULT (GETUTCDATE())
);
GO

/**
 * @primaryKey pkNewsReviewer
 * @keyType Relationship
 */
ALTER TABLE [functional].[newsReviewer]
ADD CONSTRAINT [pkNewsReviewer] PRIMARY KEY CLUSTERED ([idAccount], [idNews], [idReviewer]);
GO

/**
 * @foreignKey fkNewsReviewer_News News reference
 * @target functional.news
 */
ALTER TABLE [functional].[newsReviewer]
ADD CONSTRAINT [fkNewsReviewer_News] FOREIGN KEY ([idNews])
REFERENCES [functional].[news]([idNews]);
GO

/**
 * @table reviewComment Review comments from editors
 * @multitenancy true
 * @softDelete true
 * @alias rvwCmt
 */
CREATE TABLE [functional].[reviewComment] (
  [idReviewComment] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idNews] INTEGER NOT NULL,
  [idReviewer] INTEGER NOT NULL,
  [comment] NVARCHAR(1000) NOT NULL,
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @primaryKey pkReviewComment
 * @keyType Object
 */
ALTER TABLE [functional].[reviewComment]
ADD CONSTRAINT [pkReviewComment] PRIMARY KEY CLUSTERED ([idReviewComment]);
GO

/**
 * @foreignKey fkReviewComment_News News reference
 * @target functional.news
 */
ALTER TABLE [functional].[reviewComment]
ADD CONSTRAINT [fkReviewComment_News] FOREIGN KEY ([idNews])
REFERENCES [functional].[news]([idNews]);
GO

/**
 * @index ixReviewComment_Account_News News comments lookup
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixReviewComment_Account_News]
ON [functional].[reviewComment]([idAccount], [idNews])
WHERE [deleted] = 0;
GO

/**
 * @table statusHistory Status change history
 * @multitenancy true
 * @softDelete false
 * @alias stsHst
 */
CREATE TABLE [functional].[statusHistory] (
  [idStatusHistory] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idNews] INTEGER NOT NULL,
  [previousStatus] INTEGER NOT NULL,
  [newStatus] INTEGER NOT NULL,
  [idUser] INTEGER NOT NULL,
  [changeDate] DATETIME2 NOT NULL DEFAULT (GETUTCDATE())
);
GO

/**
 * @primaryKey pkStatusHistory
 * @keyType Object
 */
ALTER TABLE [functional].[statusHistory]
ADD CONSTRAINT [pkStatusHistory] PRIMARY KEY CLUSTERED ([idStatusHistory]);
GO

/**
 * @foreignKey fkStatusHistory_News News reference
 * @target functional.news
 */
ALTER TABLE [functional].[statusHistory]
ADD CONSTRAINT [fkStatusHistory_News] FOREIGN KEY ([idNews])
REFERENCES [functional].[news]([idNews]);
GO

/**
 * @index ixStatusHistory_Account_News News history lookup
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixStatusHistory_Account_News]
ON [functional].[statusHistory]([idAccount], [idNews]);
GO

/**
 * @table newsView News view tracking
 * @multitenancy true
 * @softDelete false
 * @alias nwsVw
 */
CREATE TABLE [functional].[newsView] (
  [idNewsView] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idNews] INTEGER NOT NULL,
  [sessionId] NVARCHAR(100) NOT NULL,
  [ipAddress] NVARCHAR(45) NOT NULL,
  [userAgent] NVARCHAR(500) NOT NULL,
  [viewDate] DATETIME2 NOT NULL DEFAULT (GETUTCDATE())
);
GO

/**
 * @primaryKey pkNewsView
 * @keyType Object
 */
ALTER TABLE [functional].[newsView]
ADD CONSTRAINT [pkNewsView] PRIMARY KEY CLUSTERED ([idNewsView]);
GO

/**
 * @foreignKey fkNewsView_News News reference
 * @target functional.news
 */
ALTER TABLE [functional].[newsView]
ADD CONSTRAINT [fkNewsView_News] FOREIGN KEY ([idNews])
REFERENCES [functional].[news]([idNews]);
GO

/**
 * @index ixNewsView_Account_News_Session Session view lookup
 * @type Performance
 */
CREATE NONCLUSTERED INDEX [ixNewsView_Account_News_Session]
ON [functional].[newsView]([idAccount], [idNews], [sessionId])
INCLUDE ([viewDate]);
GO
