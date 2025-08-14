CREATE TABLE [kcsd].[kc_loantype_detail] (
    [kc_loan_type] VARCHAR (3) NOT NULL,
    [kc_item_no]   INT         NOT NULL,
    [kc_loan_perd] INT         NOT NULL,
    [kc_give_amt]  INT         NOT NULL,
    [kc_perd_fee]  INT         NOT NULL,
    [kc_intr_fee]  INT         NOT NULL,
    [kc_add_fee]   INT         CONSTRAINT [DF__kc_loanty__kc_ad__7889D298] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_kc_loantype_detail] PRIMARY KEY CLUSTERED ([kc_loan_type] ASC, [kc_item_no] ASC)
);

