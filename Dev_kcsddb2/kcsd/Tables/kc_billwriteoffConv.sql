CREATE TABLE [kcsd].[kc_billwriteoffConv] (
    [kc_summary_code] VARCHAR (10) NOT NULL,
    [kc_pay_type]     VARCHAR (10) NULL,
    [kc_proc_fee]     INT          NULL,
    [kc_bill_code]    VARCHAR (10) NULL,
    [kc_issu_code]    VARCHAR (10) NULL,
    [kc_bill_memo]    VARCHAR (10) NULL,
    CONSTRAINT [PK_kc_billwriteoff] PRIMARY KEY CLUSTERED ([kc_summary_code] ASC)
);

