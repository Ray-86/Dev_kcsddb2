CREATE TABLE [kcsd].[InvoAllowanceMaster] (
    [CompanyID]       VARCHAR (2)   NOT NULL,
    [InvoType]        VARCHAR (2)   NOT NULL,
    [AllowanceNo]     VARCHAR (16)  NOT NULL,
    [AllowanceStatus] SMALLINT      NULL,
    [UploadStatus]    SMALLINT      NOT NULL,
    [AllowanceDate]   DATE          NOT NULL,
    [AllowanceType]   VARCHAR (1)   NOT NULL,
    [TotalAmount]     DECIMAL (10)  NOT NULL,
    [TaxAmount]       DECIMAL (10)  NOT NULL,
    [TotalTaxAmount]  DECIMAL (10)  NOT NULL,
    [CustomerID]      VARCHAR (8)   NOT NULL,
    [CancelDate]      DATE          NULL,
    [CancelTime]      VARCHAR (8)   NULL,
    [CancelReason]    VARCHAR (20)  NULL,
    [Remarks]         VARCHAR (150) NULL,
    [kc_updt_user]    VARCHAR (10)  NULL,
    [kc_updt_date]    SMALLDATETIME NULL,
    CONSTRAINT [PK_InvoAllowanceMaster_1] PRIMARY KEY CLUSTERED ([CompanyID] ASC, [InvoType] ASC, [AllowanceNo] ASC)
);

