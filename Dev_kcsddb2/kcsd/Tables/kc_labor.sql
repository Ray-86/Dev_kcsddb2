CREATE TABLE [kcsd].[kc_labor] (
    [kc_case_no]    VARCHAR (20)  NOT NULL,
    [kc_labor_stat] VARCHAR (20)  NULL,
    [kc_labor_date] SMALLDATETIME NULL,
    [kc_labor_memo] VARCHAR (200) NULL,
    [kc_updt_user]  VARCHAR (20)  NULL,
    [kc_updt_date]  SMALLDATETIME NULL,
    CONSTRAINT [PK_kc_labor] PRIMARY KEY CLUSTERED ([kc_case_no] ASC)
);

