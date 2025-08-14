CREATE TABLE [kcsd].[z_OtpLimit] (
    [id]        INT            IDENTITY (1, 1) NOT NULL,
    [ip]        NVARCHAR (20)  NULL,
    [date]      DATETIME       NULL,
    [count]     INT            NULL,
    [day]       NVARCHAR (10)  NULL,
    [member_id] INT            NULL,
    [mark]      NVARCHAR (250) NULL,
    CONSTRAINT [PK_z_OtpLimit] PRIMARY KEY CLUSTERED ([id] ASC)
);

