CREATE TABLE [kcsd].[kc_lawruling_identify] (
    [kc_file_no]    VARCHAR (10) NOT NULL,
    [kc_law_date]   DATETIME     NULL,
    [kc_law_code]   VARCHAR (1)  NULL,
    [kc_law_fmt]    VARCHAR (4)  NULL,
    [kc_court_code] VARCHAR (10) NULL,
    [kc_case_no]    VARCHAR (10) NULL,
    [kc_doc_no]     VARCHAR (40) NULL,
    [kc_doc_date]   DATETIME     NULL,
    [kc_doc_type]   VARCHAR (20) NULL,
    [kc_perm_flag]  VARCHAR (1)  NULL,
    [kc_perm_flag1] VARCHAR (1)  NULL,
    [kc_perm_flag2] VARCHAR (1)  NULL,
    [kc_fin_flag]   VARCHAR (1)  NULL,
    [CreatePerson]  VARCHAR (20) NULL,
    [CreateDate]    DATETIME     NULL,
    [kc_updt_user]  VARCHAR (20) NULL,
    [kc_updt_date]  DATETIME     NULL,
    [kc_file_name]  VARCHAR (20) NULL
);

