CREATE TABLE [kcsd].[_sys_Role] (
    [RoleCode]     VARCHAR (100)  NOT NULL,
    [RoleSeq]      VARCHAR (10)   NULL,
    [RoleName]     VARCHAR (200)  NULL,
    [Description]  VARCHAR (2048) NULL,
    [CreatePerson] VARCHAR (20)   NULL,
    [CreateDate]   DATETIME       NULL,
    [UpdatePerson] VARCHAR (20)   NULL,
    [UpdateDate]   DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([RoleCode] ASC)
);

