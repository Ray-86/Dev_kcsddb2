CREATE TABLE [kcsd].[kc_employer] (
    [kc_case_no]       VARCHAR (2)   NOT NULL,
    [kc_item_no]       SMALLINT      NOT NULL,
    [kc_employer_stat] VARCHAR (5)   NOT NULL,
    [kc_employer_name] NVARCHAR (60) NOT NULL,
    [kc_contact_name]  NVARCHAR (60) NOT NULL,
    [kc_phone_no1]     VARCHAR (15)  NULL,
    [kc_phone_no2]     VARCHAR (15)  NULL,
    [kc_fax_no]        VARCHAR (15)  NULL,
    [kc_employer_zip]  VARCHAR (5)   NULL,
    [kc_employer_addr] VARCHAR (100) NULL,
    [kc_entry_date]    SMALLDATETIME NULL,
    [CreatePerson]     VARCHAR (20)  NULL,
    [CreateDate]       DATETIME      NULL,
    [kc_updt_user]     VARCHAR (20)  NULL,
    [kc_updt_date]     DATETIME      NULL,
    CONSTRAINT [PK_kc_employer] PRIMARY KEY CLUSTERED ([kc_case_no] ASC, [kc_item_no] ASC)
);

