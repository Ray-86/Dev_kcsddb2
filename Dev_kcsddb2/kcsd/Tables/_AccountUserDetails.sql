CREATE TABLE [kcsd].[_AccountUserDetails] (
    [Uid]           INT            NOT NULL,
    [LastVisitTime] DATETIME       NOT NULL,
    [LastVisitIp]   CHAR (15)      NOT NULL,
    [RegisterTime]  DATETIME       NOT NULL,
    [RegisterIp]    CHAR (15)      NOT NULL,
    [Gender]        TINYINT        NOT NULL,
    [Address]       NVARCHAR (150) NOT NULL,
    CONSTRAINT [PK_AccountUserDetails] PRIMARY KEY CLUSTERED ([Uid] ASC)
);

