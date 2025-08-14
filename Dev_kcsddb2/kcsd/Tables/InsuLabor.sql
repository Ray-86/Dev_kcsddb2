CREATE TABLE [kcsd].[InsuLabor] (
    [kc_labor_date] DATETIME     NOT NULL,
    [kc_case_no]    VARCHAR (10) NOT NULL,
    [kc_id_no]      VARCHAR (10) NOT NULL,
    [kc_item_no]    SMALLINT     NOT NULL,
    [kc_cust_type]  VARCHAR (10) NOT NULL,
    [kc_run_date]   DATETIME     NULL,
    [kc_labor_type] VARCHAR (1)  NOT NULL,
    [kc_push_flag]  VARCHAR (1)  NOT NULL,
    [kc_updt_user]  VARCHAR (10) NOT NULL,
    [kc_updt_date]  DATETIME     NOT NULL
);

