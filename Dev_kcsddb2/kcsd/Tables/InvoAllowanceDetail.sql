CREATE TABLE [kcsd].[InvoAllowanceDetail] (
    [CompanyID]               VARCHAR (2)     NOT NULL,
    [InvoType]                VARCHAR (2)     NOT NULL,
    [AllowanceNo]             VARCHAR (16)    NOT NULL,
    [AllowanceSequenceNumber] VARCHAR (3)     NOT NULL,
    [OriginalInvoiceDate]     DATE            NOT NULL,
    [OriginalInvoiceNumber]   VARCHAR (10)    NOT NULL,
    [OriginalSequenceNumber]  VARCHAR (3)     NOT NULL,
    [OriginalDescription]     VARCHAR (30)    NOT NULL,
    [Quantity]                DECIMAL (10, 2) NOT NULL,
    [UnitPrice]               DECIMAL (10, 2) NOT NULL,
    [Amount]                  DECIMAL (10, 2) NOT NULL,
    [Tax]                     DECIMAL (10, 2) NOT NULL,
    [TaxType]                 VARCHAR (1)     NOT NULL,
    [kc_updt_user]            VARCHAR (10)    NULL,
    [kc_updt_date]            SMALLDATETIME   NULL,
    CONSTRAINT [PK_InvoAllowanceDetail] PRIMARY KEY CLUSTERED ([CompanyID] ASC, [InvoType] ASC, [AllowanceNo] ASC, [AllowanceSequenceNumber] ASC)
);

