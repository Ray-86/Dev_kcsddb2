CREATE TABLE [kcsd].[z_VerifyM1] (
    [id]               INT            IDENTITY (1, 1) NOT NULL,
    [idno]             NVARCHAR (50)  NULL,
    [mobilno]          NVARCHAR (50)  NULL,
    [clausever]        NVARCHAR (50)  NULL,
    [Operator]         NVARCHAR (50)  NULL,
    [type]             INT            NULL,
    [twca_return_desc] NVARCHAR (250) NULL,
    [add_time]         DATETIME       NULL,
    [twca_key_count]   FLOAT (53)     NULL,
    CONSTRAINT [PK_z_VerifyM1] PRIMARY KEY CLUSTERED ([id] ASC)
);

