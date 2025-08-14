CREATE TABLE [kcsd].[_sys_Menu] (
    [MenuCode]     VARCHAR (100)  NOT NULL,
    [ParentCode]   VARCHAR (100)  NULL,
    [MenuName]     VARCHAR (200)  NULL,
    [URL]          VARCHAR (200)  NULL,
    [IconClass]    VARCHAR (50)   NULL,
    [MenuSeq]      VARCHAR (10)   NULL,
    [Description]  VARCHAR (2048) NULL,
    [IsVisible]    BIT            NULL,
    [IsEnable]     BIT            NULL,
    [CreatePerson] VARCHAR (20)   NULL,
    [CreateDate]   DATETIME       NULL,
    [UpdatePerson] VARCHAR (20)   NULL,
    [UpdateDate]   DATETIME       NULL,
    CONSTRAINT [PK_menu] PRIMARY KEY CLUSTERED ([MenuCode] ASC)
);

