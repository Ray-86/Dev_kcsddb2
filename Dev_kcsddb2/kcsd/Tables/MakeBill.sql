CREATE TABLE [kcsd].[MakeBill] (
    [kc_case_no]     VARCHAR (10) NOT NULL,
    [kc_item_no]     INT          NOT NULL,
    [kc_expt_date]   DATETIME     NOT NULL,
    [kc_pay_date]    DATETIME     NULL,
    [kc_pay_fee]     INT          NOT NULL,
    [kc_break_fee]   INT          NOT NULL,
    [kc_acct_bar1]   VARCHAR (20) NOT NULL,
    [kc_acct_bar2]   VARCHAR (20) NOT NULL,
    [kc_acct_bar3]   VARCHAR (20) NOT NULL,
    [kc_export_flag] VARCHAR (1)  NULL,
    [kc_short_code]  VARCHAR (8)  NULL,
    [kc_crdt_user]   VARCHAR (20) NULL,
    [kc_crdt_date]   DATETIME     NULL,
    [kc_updt_user]   VARCHAR (20) NULL,
    [kc_updt_date]   DATETIME     NULL,
    [CreatePerson]   VARCHAR (20) NULL,
    [CreateDate]     DATETIME     NULL,
    [kc_ATM_codeB]   VARCHAR (20) NULL,
    CONSTRAINT [PK_MakeBill] PRIMARY KEY CLUSTERED ([kc_case_no] ASC, [kc_item_no] ASC)
);

