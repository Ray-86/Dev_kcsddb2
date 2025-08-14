CREATE TABLE [kcsd].[kc_zzfix_invo] (
    [kc_case_no]   VARCHAR (10) NOT NULL,
    [kc_over_amt]  INT          NOT NULL,
    [kc_perd_no]   INT          NULL,
    [kc_loan_perd] INT          NULL,
    [kc_pay_perd]  INT          NULL,
    [kc_invo_diff] INT          NULL,
    CONSTRAINT [PK_kc_zzfix_invo] PRIMARY KEY CLUSTERED ([kc_case_no] ASC)
);

