CREATE TABLE [kcsd].[kc_sysnotice] (
    [kc_list_no]   VARCHAR (10)  NOT NULL,
    [kc_sys_date]  DATETIME      NULL,
    [kc_sys_note]  VARCHAR (100) NULL,
    [CreatePerson] VARCHAR (10)  NULL,
    [CreateDate]   SMALLDATETIME NULL,
    [kc_updt_user] VARCHAR (10)  NULL,
    [kc_updt_date] SMALLDATETIME NULL
);

