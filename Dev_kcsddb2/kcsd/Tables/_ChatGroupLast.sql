CREATE TABLE [kcsd].[_ChatGroupLast] (
    [id]       INT          IDENTITY (1, 1) NOT NULL,
    [Chatid]   INT          NOT NULL,
    [ToGroup]  VARCHAR (10) NULL,
    [LastDate] DATETIME     NULL,
    [InGroup]  BIT          NULL,
    CONSTRAINT [PK_ChatGroupLast] PRIMARY KEY CLUSTERED ([id] ASC)
);

