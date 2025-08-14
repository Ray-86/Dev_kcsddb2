CREATE TABLE [kcsd].[InvoBranchTrack] (
    [CompanyID]      VARCHAR (2)   NOT NULL,
    [InvoYear]       VARCHAR (3)   NOT NULL,
    [InvoMonth]      VARCHAR (2)   NOT NULL,
    [InvoType]       VARCHAR (2)   NOT NULL,
    [Books]          VARCHAR (4)   NOT NULL,
    [InvoiceTrack]   VARCHAR (2)   NOT NULL,
    [InvoiceBeginNo] VARCHAR (8)   NOT NULL,
    [InvoiceEndNo]   VARCHAR (8)   NOT NULL,
    [InvoiceNowNo]   VARCHAR (8)   NOT NULL,
    [SalesAmount]    DECIMAL (18)  NOT NULL,
    [TaxAmount]      DECIMAL (18)  NOT NULL,
    [ZeroAmount]     DECIMAL (18)  NOT NULL,
    [FreeAmount]     DECIMAL (18)  NOT NULL,
    [PsnAmount]      DECIMAL (18)  NOT NULL,
    [PsnSales]       DECIMAL (18)  NOT NULL,
    [PsnTax]         DECIMAL (18)  NOT NULL,
    [NotUse]         DECIMAL (8)   NOT NULL,
    [Void]           DECIMAL (8)   NOT NULL,
    [kc_updt_user]   VARCHAR (10)  NULL,
    [kc_updt_date]   SMALLDATETIME NULL,
    CONSTRAINT [PK_InvoBranchTrack] PRIMARY KEY CLUSTERED ([CompanyID] ASC, [InvoYear] ASC, [InvoMonth] ASC, [InvoType] ASC, [Books] ASC, [InvoiceTrack] ASC, [InvoiceBeginNo] ASC, [InvoiceEndNo] ASC)
);

