CREATE TABLE [kcsd].[_sys_UserRoleMap] (
    [ID]       INT           IDENTITY (1, 1) NOT NULL,
    [uid]      INT           NULL,
    [RoleCode] VARCHAR (100) NULL,
    CONSTRAINT [PK__userRole__3214EC278CC368FA] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_sys_UserRoleMap_sys_Role] FOREIGN KEY ([RoleCode]) REFERENCES [kcsd].[_sys_Role] ([RoleCode])
);

