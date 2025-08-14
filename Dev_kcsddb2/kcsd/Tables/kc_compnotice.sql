CREATE TABLE [kcsd].[kc_compnotice] (
    [kc_list_no]     VARCHAR (10)  NOT NULL,
    [kc_notice_date] DATETIME      NULL,
    [kc_notice_note] VARCHAR (100) NULL,
    [kc_notice_att]  VARCHAR (100) NULL,
    [CreatePerson]   VARCHAR (10)  NULL,
    [CreateDate]     SMALLDATETIME NULL,
    [kc_updt_user]   VARCHAR (10)  NULL,
    [kc_updt_date]   SMALLDATETIME NULL
);

