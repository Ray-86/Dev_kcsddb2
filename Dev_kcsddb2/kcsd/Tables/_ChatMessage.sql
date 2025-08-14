CREATE TABLE [kcsd].[_ChatMessage] (
    [id]             INT           IDENTITY (1, 1) NOT NULL,
    [Chatid]         INT           NOT NULL,
    [MessageType]    VARCHAR (10)  NULL,
    [MessageContent] VARCHAR (500) NULL,
    [MessageDate]    DATETIME      NULL,
    [MessageIP]      VARCHAR (15)  NULL,
    [ToGroup]        VARCHAR (10)  NULL,
    CONSTRAINT [PK_ChatMessage] PRIMARY KEY CLUSTERED ([id] ASC)
);

