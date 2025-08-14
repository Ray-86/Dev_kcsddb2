CREATE TABLE [kcsd].[InvoMaster] (
    [CompanyID]               VARCHAR (2)   NOT NULL,
    [InvoYear]                VARCHAR (3)   NOT NULL,
    [InvoMonth]               VARCHAR (2)   NOT NULL,
    [InvoNo]                  VARCHAR (10)  NOT NULL,
    [InvoStatus]              SMALLINT      NOT NULL,
    [UploadStatus]            SMALLINT      NOT NULL,
    [InvoType]                VARCHAR (2)   NOT NULL,
    [InvoDate]                DATE          NOT NULL,
    [InvoTime]                VARCHAR (8)   NOT NULL,
    [RandomNumber]            VARCHAR (4)   NOT NULL,
    [DonateMark]              VARCHAR (1)   NOT NULL,
    [CarrierType]             VARCHAR (6)   NULL,
    [CarrierId1]              VARCHAR (64)  NULL,
    [CarrierId2]              VARCHAR (64)  NULL,
    [PrintMark]               VARCHAR (1)   NOT NULL,
    [NPOBAN]                  VARCHAR (7)   NULL,
    [BarCode]                 VARCHAR (50)  NOT NULL,
    [QRcodeL]                 VARCHAR (200) NOT NULL,
    [QRcodeR]                 VARCHAR (200) NOT NULL,
    [CustomerID]              VARCHAR (8)   NOT NULL,
    [TaxType]                 VARCHAR (1)   NOT NULL,
    [DeliveryID]              VARCHAR (10)  NOT NULL,
    [SubTotal]                DECIMAL (10)  NOT NULL,
    [TaxAmount]               DECIMAL (10)  NOT NULL,
    [TotalAmount]             DECIMAL (10)  NOT NULL,
    [IsPrint]                 VARCHAR (1)   NOT NULL,
    [PrintTimes]              DECIMAL (3)   NOT NULL,
    [CancelDate]              DATE          NULL,
    [CancelTime]              VARCHAR (8)   NULL,
    [CancelReason]            VARCHAR (20)  NULL,
    [ReturnTaxDocumentNumber] VARCHAR (60)  NULL,
    [Remarks]                 VARCHAR (150) NULL,
    [kc_updt_user]            VARCHAR (10)  NULL,
    [kc_updt_date]            SMALLDATETIME NULL,
    [rtn_flag]                VARCHAR (1)   NULL,
    [CompID]                  VARCHAR (20)  NULL,
    CONSTRAINT [PK_InvoMaster_1] PRIMARY KEY CLUSTERED ([CompanyID] ASC, [InvoYear] ASC, [InvoMonth] ASC, [InvoNo] ASC)
);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20170831-153504]
    ON [kcsd].[InvoMaster]([CustomerID] ASC, [InvoNo] ASC);

