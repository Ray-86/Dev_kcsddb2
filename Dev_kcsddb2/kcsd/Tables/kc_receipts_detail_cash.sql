CREATE TABLE [kcsd].[kc_receipts_detail_cash] (
    [kc_receipts_catalog]    NVARCHAR (12)  NOT NULL,
    [kc_receipts_id]         INT            NOT NULL,
    [kc_area_code]           NVARCHAR (2)   NOT NULL,
    [kc_case_no]             NVARCHAR (10)  NOT NULL,
    [kc_receipt_type]        NVARCHAR (2)   NOT NULL,
    [kc_receipt_no]          NVARCHAR (10)  NOT NULL,
    [kc_receipt_fee]         INT            NOT NULL,
    [kc_receipt_memo]        NVARCHAR (100) NULL,
    [kc_receipt_breakamt]    INT            CONSTRAINT [DF_kc_receipts_detail_cash_kc_receipt_breakamt] DEFAULT ((0)) NOT NULL,
    [kc_receipt_advancetype] NVARCHAR (2)   NULL,
    [kc_recorded_user]       VARCHAR (20)   NULL,
    [kc_recorded_date]       SMALLDATETIME  NULL,
    [CreatePerson]           VARCHAR (20)   NULL,
    [CreateDate]             DATETIME       NULL,
    [kc_updt_user]           VARCHAR (20)   NULL,
    [kc_updt_date]           DATETIME       NULL,
    CONSTRAINT [PK_kc_receipts_detail_cash] PRIMARY KEY CLUSTERED ([kc_receipts_catalog] ASC, [kc_receipts_id] ASC)
);

