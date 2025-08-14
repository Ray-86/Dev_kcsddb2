CREATE TABLE [kcsd].[kc_icard] (
    [kc_icard_no]   VARCHAR (9)   NOT NULL,
    [kc_icard_date] SMALLDATETIME NOT NULL,
    [kc_appl_type]  VARCHAR (1)   NOT NULL,
    [kc_emp_code]   VARCHAR (6)   NULL,
    [kc_vend_code]  VARCHAR (4)   NULL,
    [kc_lock_amt]   TINYINT       NOT NULL,
    [kc_updt_user]  VARCHAR (10)  NULL,
    [kc_updt_date]  SMALLDATETIME NULL,
    [kc_lock_amt2]  TINYINT       NULL,
    [kc_lock_amt3]  TINYINT       NULL,
    [kc_icard_type] VARCHAR (2)   NULL,
    [kc_icard_stat] VARCHAR (1)   NULL,
    [kc_scrap_date] SMALLDATETIME NULL,
    [kc_icard_note] VARCHAR (150) NULL,
    [kc_lock_type]  VARCHAR (30)  NULL,
    [kc_vend_code2] VARCHAR (4)   NULL,
    CONSTRAINT [PK_kc_icard_1__20] PRIMARY KEY CLUSTERED ([kc_icard_no] ASC)
);

