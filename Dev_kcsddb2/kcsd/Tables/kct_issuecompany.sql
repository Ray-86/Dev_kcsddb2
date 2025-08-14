CREATE TABLE [kcsd].[kct_issuecompany] (
    [kc_issu_code]  VARCHAR (6)   NOT NULL,
    [kc_issu_desc]  VARCHAR (50)  NOT NULL,
    [kc_boss_name]  VARCHAR (10)  NULL,
    [kc_uniform_no] VARCHAR (18)  NULL,
    [kc_acct_no]    VARCHAR (8)   NULL,
    [kc_id_no]      VARCHAR (10)  NULL,
    [kc_atm_no]     VARCHAR (10)  NULL,
    [kc_issu_addr]  NVARCHAR (50) NULL,
    [kc_card_no]    VARCHAR (16)  NULL,
    [kc_card_date]  VARCHAR (4)   NULL,
    CONSTRAINT [PK_kct_issuecompany] PRIMARY KEY CLUSTERED ([kc_issu_code] ASC)
);

