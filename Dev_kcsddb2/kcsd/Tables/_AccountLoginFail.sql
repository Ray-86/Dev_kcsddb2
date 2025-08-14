CREATE TABLE [kcsd].[_AccountLoginFail] (
    [Id]            INT      IDENTITY (1, 1) NOT NULL,
    [LoginIp]       BIGINT   NOT NULL,
    [FailTimes]     TINYINT  NOT NULL,
    [LastLoginTime] DATETIME NOT NULL,
    CONSTRAINT [PK_AccountLoginFail] PRIMARY KEY CLUSTERED ([Id] ASC)
);

