CREATE TABLE [kcsd].[kc_banktransfer] (
    [kc_case_no]     VARCHAR (10)  NOT NULL,
    [kc_tran_stat]   VARCHAR (2)   NOT NULL,
    [kc_appr_date]   DATETIME      NULL,
    [kc_appr_user]   VARCHAR (20)  NULL,
    [kc_rele_date]   DATETIME      NULL,
    [kc_rele_user]   VARCHAR (20)  NULL,
    [kc_pay_date]    DATETIME      NULL,
    [kc_pay_user]    VARCHAR (20)  NULL,
    [kc_rej_date]    DATETIME      NULL,
    [kc_rej_user]    VARCHAR (20)  NULL,
    [kc_rejfin_date] DATETIME      NULL,
    [kc_rejfin_user] VARCHAR (20)  NULL,
    [kc_insu_fig]    VARCHAR (2)   NULL,
    [kc_close_fig]   VARCHAR (2)   NULL,
    [kc_cancel_fig]  VARCHAR (2)   NULL,
    [kc_data_memo]   VARCHAR (150) NULL
);

