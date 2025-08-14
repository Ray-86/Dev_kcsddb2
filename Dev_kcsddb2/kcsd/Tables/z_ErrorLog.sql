CREATE TABLE [kcsd].[z_ErrorLog] (
    [id]        INT             IDENTITY (1, 1) NOT NULL,
    [member_id] INT             NULL,
    [store_id]  INT             NULL,
    [item]      NVARCHAR (50)   NULL,
    [desc_log]  NVARCHAR (1500) NULL,
    [time]      DATETIME        NULL,
    [date]      NVARCHAR (10)   NULL,
    [cp_no]     NVARCHAR (10)   NULL,
    [id_no]     NVARCHAR (10)   NULL,
    [member_no] NVARCHAR (11)   NULL,
    [browser]   NVARCHAR (50)   NULL,
    [level_log] INT             NULL,
    CONSTRAINT [PK_z_Log] PRIMARY KEY CLUSTERED ([id] ASC)
);

