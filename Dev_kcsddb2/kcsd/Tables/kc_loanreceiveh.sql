CREATE TABLE [kcsd].[kc_loanreceiveh] (
    [kc_receive_no] VARCHAR (12)  NULL,
    [kc_area_code]  VARCHAR (2)   NULL,
    [kc_pay_date]   DATETIME      NULL,
    [kc_pay_type]   VARCHAR (1)   NULL,
    [kc_pay_fee]    INT           NULL,
    [kc_break_fee]  INT           NULL,
    [kc_oper_code]  VARCHAR (6)   NULL,
    [kc_trans_no]   VARCHAR (10)  NULL,
    [kc_case_no]    VARCHAR (10)  NULL,
    [kc_emp_code]   VARCHAR (6)   NULL,
    [kc_data_memo]  VARCHAR (150) NULL,
    [kc_updt_user]  VARCHAR (10)  NULL,
    [kc_updt_date]  SMALLDATETIME NULL
);

