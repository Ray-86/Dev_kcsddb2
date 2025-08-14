CREATE TABLE [kcsd].[z_ProductClass] (
    [product_class_id] INT           IDENTITY (1, 1) NOT NULL,
    [member_id]        INT           NULL,
    [store_no]         NVARCHAR (10) NULL,
    [class_name]       NVARCHAR (20) NULL,
    [add_time]         DATETIME      NULL,
    CONSTRAINT [PK_z_ProductClass] PRIMARY KEY CLUSTERED ([product_class_id] ASC)
);

