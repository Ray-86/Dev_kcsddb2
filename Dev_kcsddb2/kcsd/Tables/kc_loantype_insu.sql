CREATE TABLE [kcsd].[kc_loantype_insu] (
    [kc_loan_type]     VARCHAR (2) NOT NULL,
    [kc_item_no]       INT         NOT NULL,
    [kc_give_amt]      INT         NOT NULL,
    [kc_insu_type]     VARCHAR (4) NOT NULL,
    [kc_insu_downline] INT         NOT NULL,
    [kc_insu_upline]   INT         NOT NULL,
    CONSTRAINT [PK_kc_loantype_insu] PRIMARY KEY CLUSTERED ([kc_loan_type] ASC, [kc_item_no] ASC)
);

