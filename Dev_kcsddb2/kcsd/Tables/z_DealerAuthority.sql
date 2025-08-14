CREATE TABLE [kcsd].[z_DealerAuthority] (
    [id]        INT           IDENTITY (1, 1) NOT NULL,
    [store_no]  NVARCHAR (50) NULL,
    [authority] NVARCHAR (50) NULL,
    CONSTRAINT [PK_z_DealerAuthority] PRIMARY KEY CLUSTERED ([id] ASC)
);

