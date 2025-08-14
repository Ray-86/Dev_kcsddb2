CREATE TABLE [kcsd].[kc_balance] (
    [kc_perd_year]  SMALLINT    NOT NULL,
    [kc_perd_month] TINYINT     NOT NULL,
    [kc_comp_char]  VARCHAR (1) NOT NULL,
    [kc_perd_seq]   SMALLINT    NULL,
    [kc_loan_fee]   MONEY       CONSTRAINT [DF_kc_balance_kc_loan_fee3__14] DEFAULT ((0)) NULL,
    [kc_loan_ret]   MONEY       CONSTRAINT [DF_kc_balance_kc_loan_ret4__14] DEFAULT ((0)) NULL,
    [kc_perd_inve]  MONEY       CONSTRAINT [DF_kc_balance_kc_perd_inv8__14] DEFAULT ((0)) NULL,
    [kc_perd_expt]  MONEY       CONSTRAINT [DF_kc_balance_kc_perd_exp7__14] DEFAULT ((0)) NULL,
    [kc_prev_expt]  MONEY       CONSTRAINT [DF_kc_balance_kc_prev_exp9__14] DEFAULT ((0)) NULL,
    [kc_pay_sum]    MONEY       CONSTRAINT [DF_kc_balance_kc_pay_sum_6__14] DEFAULT ((0)) NULL,
    [kc_pay_fee]    MONEY       CONSTRAINT [DF_kc_balance_kc_pay_fee_5__14] DEFAULT ((0)) NULL,
    [kc_break_fee]  MONEY       CONSTRAINT [DF_kc_balance_kc_break_fe1__14] DEFAULT ((0)) NULL,
    [kc_intr_fee]   MONEY       CONSTRAINT [DF_kc_balance_kc_intr_fee2__14] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_kc_balance_1__15] PRIMARY KEY CLUSTERED ([kc_perd_year] ASC, [kc_perd_month] ASC, [kc_comp_char] ASC)
);

