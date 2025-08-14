CREATE TABLE [kcsd].[_ChatUserOnline] (
    [Chatid]      INT          IDENTITY (1, 1) NOT NULL,
    [ConnectId]   VARCHAR (50) NULL,
    [OnlineDate]  DATETIME     NULL,
    [OfflineDate] DATETIME     NULL,
    [UserIP]      VARCHAR (15) NULL,
    [IsOnline]    BIT          NULL,
    CONSTRAINT [PK_ChatUserOnline] PRIMARY KEY CLUSTERED ([Chatid] ASC)
);

