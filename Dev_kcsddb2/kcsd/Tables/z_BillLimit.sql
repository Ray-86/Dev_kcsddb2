CREATE TABLE [kcsd].[z_BillLimit] (
    [id]        INT             IDENTITY (1, 1) NOT NULL,
    [date]      DATETIME        NULL,
    [day]       NVARCHAR (10)   NULL,
    [count]     INT             NULL,
    [member_no] NVARCHAR (11)   NULL,
    [pay_fee]   INT             NULL,
    [break_fee] INT             NULL,
    [interest]  INT             NULL,
    [bill_json] NVARCHAR (1000) NULL,
    [duduPoint] INT             NULL,
    CONSTRAINT [PK_z_BillLimit] PRIMARY KEY CLUSTERED ([id] ASC)
);

