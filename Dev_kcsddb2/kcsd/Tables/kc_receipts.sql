CREATE TABLE [kcsd].[kc_receipts] (
    [kc_receipts_catalog] NVARCHAR (12) NOT NULL,
    [kc_receipts_date]    SMALLDATETIME NOT NULL,
    [kc_area_code]        NVARCHAR (2)  NOT NULL,
    [kc_receipts_user]    NVARCHAR (50) NOT NULL,
    [kc_cashier_user]     NVARCHAR (50) NULL,
    [kc_cashier_date]     SMALLDATETIME NULL,
    [kc_treasurer_user]   NVARCHAR (50) NULL,
    [kc_treasurer_date]   SMALLDATETIME NULL,
    [CreatePerson]        VARCHAR (20)  NULL,
    [CreateDate]          DATETIME      NULL,
    [kc_updt_user]        VARCHAR (20)  NULL,
    [kc_updt_date]        DATETIME      NULL,
    CONSTRAINT [PK_kc_receipts] PRIMARY KEY CLUSTERED ([kc_receipts_catalog] ASC)
);

