CREATE TABLE [kcsd].[kc_receipts_detail_check] (
    [kc_receipts_catalog] NVARCHAR (12) NOT NULL,
    [kc_receipts_id]      INT           NOT NULL,
    [kc_area_code]        NVARCHAR (2)  NOT NULL,
    [kc_check_user]       NVARCHAR (10) NOT NULL,
    [kc_check_date]       SMALLDATETIME NOT NULL,
    [kc_check_no]         NVARCHAR (10) NOT NULL,
    [kc_check_fee]        INT           NOT NULL,
    [CreatePerson]        VARCHAR (20)  NULL,
    [CreateDate]          DATETIME      NULL,
    [kc_updt_user]        VARCHAR (20)  NULL,
    [kc_updt_date]        DATETIME      NULL,
    CONSTRAINT [PK_kc_receipts_detail_check] PRIMARY KEY CLUSTERED ([kc_receipts_catalog] ASC, [kc_receipts_id] ASC)
);

