CREATE TABLE [kcsd].[kc_checkbak] (
    [kc_acc_code]   VARCHAR (2)   NOT NULL,
    [kc_chk_no]     VARCHAR (7)   NOT NULL,
    [kc_write_date] SMALLDATETIME NOT NULL,
    [kc_pay_date]   SMALLDATETIME NOT NULL,
    [kc_pay_amt]    INT           NOT NULL,
    [kc_rece_name]  VARCHAR (30)  NOT NULL,
    [kc_chk_type]   VARCHAR (2)   NOT NULL,
    [kc_chk_memo]   VARCHAR (50)  NULL,
    [kc_chk_stat]   VARCHAR (1)   NOT NULL,
    [kc_wdrw_date]  SMALLDATETIME NULL,
    [kc_updt_user]  VARCHAR (10)  NULL,
    [kc_updt_date]  SMALLDATETIME NULL,
    [kc_acc_ymd]    VARCHAR (8)   NULL,
    [kc_case_no]    VARCHAR (10)  NULL
);

