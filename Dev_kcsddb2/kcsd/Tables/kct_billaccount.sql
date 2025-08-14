CREATE TABLE [kcsd].[kct_billaccount] (
    [kc_bill_code]  VARCHAR (4)   NOT NULL,
    [kc_issu_code]  VARCHAR (2)   NOT NULL,
    [kc_cap_code]   VARCHAR (2)   NOT NULL,
    [kc_bill_store] VARCHAR (3)   NULL,
    [kc_bill_acc]   VARCHAR (7)   NULL,
    [kc_bill_memo]  VARCHAR (150) NULL,
    [CreatePerson]  VARCHAR (20)  NULL,
    [CreateDate]    DATETIME      NULL,
    [kc_updt_user]  VARCHAR (20)  NULL,
    [kc_updt_date]  DATETIME      NULL,
    [kc_atm_code]   VARCHAR (10)  NULL,
    [kc_atm_desc]   VARCHAR (20)  NULL,
    [kc_atm_acc]    VARCHAR (7)   NULL,
    [kc_post_acc]   VARCHAR (8)   NULL,
    [kc_loan_perd]  INT           NULL,
    [kc_expt_fee]   INT           NULL,
    CONSTRAINT [PK_kct_billaccount] PRIMARY KEY CLUSTERED ([kc_bill_code] ASC, [kc_issu_code] ASC, [kc_cap_code] ASC)
);

