CREATE TABLE [kcsd].[kc_customerdelete] (
    [kc_case_no]   VARCHAR (10) NOT NULL,
    [kc_pay_amt]   INT          NULL,
    [kc_del_type]  VARCHAR (2)  NULL,
    [kc_cfm_user]  VARCHAR (20) NULL,
    [kc_cfm_date]  DATETIME     NULL,
    [CreatePerson] VARCHAR (20) NULL,
    [CreateDate]   DATETIME     NULL,
    [kc_updt_user] VARCHAR (20) NULL,
    [kc_updt_date] DATETIME     NULL,
    CONSTRAINT [PK_kc_customerdelete] PRIMARY KEY CLUSTERED ([kc_case_no] ASC)
);

