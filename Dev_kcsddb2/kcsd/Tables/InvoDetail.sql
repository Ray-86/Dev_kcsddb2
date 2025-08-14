CREATE TABLE [kcsd].[InvoDetail] (
    [CompanyID]    VARCHAR (2)     NOT NULL,
    [InvoYear]     VARCHAR (3)     NOT NULL,
    [InvoMonth]    VARCHAR (2)     NOT NULL,
    [InvoNo]       VARCHAR (10)    NOT NULL,
    [InvoItem]     VARCHAR (3)     NOT NULL,
    [ProductName]  VARCHAR (30)    NOT NULL,
    [UnitPrice]    DECIMAL (10, 2) NOT NULL,
    [Quantity]     DECIMAL (10, 2) NOT NULL,
    [Amount]       DECIMAL (10, 2) NOT NULL,
    [Tax]          DECIMAL (10, 2) NULL,
    [kc_updt_user] VARCHAR (10)    NULL,
    [kc_updt_date] SMALLDATETIME   NULL,
    CONSTRAINT [PK_InvoDetail] PRIMARY KEY CLUSTERED ([CompanyID] ASC, [InvoYear] ASC, [InvoMonth] ASC, [InvoNo] ASC, [InvoItem] ASC)
);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20170831-153938]
    ON [kcsd].[InvoDetail]([CompanyID] ASC, [InvoNo] ASC, [ProductName] ASC);

