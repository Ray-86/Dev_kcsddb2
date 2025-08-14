CREATE TABLE [kcsd].[kc_IncomeList] (
    [kc_file_no]     VARCHAR (10)  NOT NULL,
    [kc_case_no]     VARCHAR (10)  NULL,
    [kc_id_type]     VARCHAR (1)   NULL,
    [kc_cust_name]   VARCHAR (20)  NULL,
    [kc_Income_fee]  INT           NULL,
    [CreatePerson]   VARCHAR (10)  NULL,
    [CreateDate]     SMALLDATETIME NULL,
    [kc_updt_user]   VARCHAR (10)  NULL,
    [kc_updt_date]   SMALLDATETIME NULL,
    [kc_file_name]   VARCHAR (20)  NULL,
    [kc_finish_type] VARCHAR (1)   NULL,
    CONSTRAINT [PK_kc_IncomeList] PRIMARY KEY CLUSTERED ([kc_file_no] ASC)
);

