CREATE TABLE [kcsd].[z_DealerBranch] (
    [id]       INT           IDENTITY (1, 1) NOT NULL,
    [store_no] NVARCHAR (50) NULL,
    [branch]   NVARCHAR (50) NULL,
    CONSTRAINT [PK_z_DealerBranch] PRIMARY KEY CLUSTERED ([id] ASC)
);

