CREATE TABLE [kcsd].[InvoCompany] (
    [CompanyID]      VARCHAR (2)   NOT NULL,
    [AttribName]     VARCHAR (10)  NOT NULL,
    [CompanyName]    VARCHAR (60)  NOT NULL,
    [EarNo]          VARCHAR (8)   NOT NULL,
    [TaxNo]          VARCHAR (9)   NOT NULL,
    [Address]        VARCHAR (100) NOT NULL,
    [PersonInCharge] VARCHAR (30)  NOT NULL,
    [TelNumber]      VARCHAR (26)  NOT NULL,
    [FaxNumber]      VARCHAR (26)  NOT NULL,
    [AESKey]         VARCHAR (32)  NOT NULL,
    [kc_updt_user]   VARCHAR (10)  NULL,
    [kc_updt_date]   SMALLDATETIME NULL,
    CONSTRAINT [PK_Company] PRIMARY KEY CLUSTERED ([CompanyID] ASC)
);

