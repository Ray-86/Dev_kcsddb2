CREATE TABLE [kcsd].[z_DealerRole] (
    [id]          INT           IDENTITY (1, 1) NOT NULL,
    [store_no]    NVARCHAR (50) NULL,
    [dealer_name] NVARCHAR (50) NULL,
    [authority]   NVARCHAR (50) NULL,
    [isCheck]     BIT           NULL,
    CONSTRAINT [PK_z_DealerRole] PRIMARY KEY CLUSTERED ([id] ASC)
);

