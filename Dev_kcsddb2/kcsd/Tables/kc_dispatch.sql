CREATE TABLE [kcsd].[kc_dispatch] (
    [kc_case_no]     VARCHAR (10)  NOT NULL,
    [kc_emp_code]    VARCHAR (6)   NOT NULL,
    [kc_pusher_date] SMALLDATETIME NOT NULL,
    [kc_pend_date]   SMALLDATETIME NULL,
    [kc_updt_user]   VARCHAR (10)  NULL,
    [kc_updt_date]   SMALLDATETIME NULL
);

