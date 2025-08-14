CREATE TABLE [kcsd].[kc_loanreceived] (
    [kc_receive_no] VARCHAR (12)  NULL,
    [kc_area_code]  VARCHAR (2)   NULL,
    [kc_item_no]    SMALLINT      NULL,
    [kc_rece_date]  DATETIME      NULL,
    [kc_case_no]    VARCHAR (10)  NULL,
    [kc_pay_type]   VARCHAR (2)   NULL,
    [kc_pay_fee]    INT           NULL,
    [kc_emp_code]   VARCHAR (6)   NULL,
    [kc_insu_flag]  VARCHAR (1)   NULL,
    [kc_data_memo]  VARCHAR (150) NULL,
    [kc_updt_user]  VARCHAR (10)  NULL,
    [kc_updt_date]  SMALLDATETIME NULL,
    [kc_break_fee]  INT           NULL
);

