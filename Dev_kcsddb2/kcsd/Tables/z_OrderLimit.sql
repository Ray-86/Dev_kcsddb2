CREATE TABLE [kcsd].[z_OrderLimit] (
    [id]    INT            IDENTITY (1, 1) NOT NULL,
    [ip]    NVARCHAR (20)  NULL,
    [date]  DATETIME       NULL,
    [count] INT            NULL,
    [day]   NVARCHAR (10)  NULL,
    [mark]  NVARCHAR (250) NULL,
    CONSTRAINT [PK_z_OrderLimit] PRIMARY KEY CLUSTERED ([id] ASC)
);

