CREATE TABLE [kcsd].[z_Store] (
    [member_id]   INT           NULL,
    [store_no]    NVARCHAR (50) NULL,
    [item]        NVARCHAR (50) NULL,
    [price]       INT           NULL,
    [id]          INT           IDENTITY (1, 1) NOT NULL,
    [date]        DATETIME      NULL,
    [typeDate]    NVARCHAR (1)  NULL,
    [today]       DATETIME      NULL,
    [date_s]      DATETIME      NULL,
    [date_e]      DATETIME      NULL,
    [type_code]   INT           NULL,
    [code_time]   NVARCHAR (20) NULL,
    [upd_date]    DATETIME      NULL,
    [upd_user]    NVARCHAR (50) NULL,
    [create_user] NVARCHAR (50) NULL,
    [del_flag]    NVARCHAR (1)  NULL,
    CONSTRAINT [PK_z_Store] PRIMARY KEY CLUSTERED ([id] ASC)
);

