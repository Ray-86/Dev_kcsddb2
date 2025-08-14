CREATE TABLE [kcsd].[z_Product] (
    [product_id]     INT            IDENTITY (1, 1) NOT NULL,
    [product_name]   NVARCHAR (150) NULL,
    [date_s]         DATETIME       NULL,
    [date_e]         DATETIME       NULL,
    [product_status] NVARCHAR (1)   NULL,
    [product_desc]   NVARCHAR (MAX) NULL,
    [product_spec]   NVARCHAR (MAX) NULL,
    [product_class]  NVARCHAR (MAX) NULL,
    [member_id]      INT            NULL,
    [store_no]       NVARCHAR (10)  NULL,
    CONSTRAINT [PK_z_Product] PRIMARY KEY CLUSTERED ([product_id] ASC)
);

