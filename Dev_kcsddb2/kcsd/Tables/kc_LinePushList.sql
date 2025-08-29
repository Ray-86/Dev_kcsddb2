CREATE TABLE [kcsd].[kc_LinePushList] (
    [kc_list_no]      VARCHAR (10)  NOT NULL,
    [kc_list_date]    DATETIME      NULL,
    [kc_list_type]    VARCHAR (1)   NULL,
    [kc_list_main]    VARCHAR (100) NULL,
    [kc_line_channel] VARCHAR (20)  NULL,
    [kc_list_memo]    VARCHAR (100) NULL,
    [kc_apply_user]   VARCHAR (10)  NULL,
    [kc_apply_date]   DATETIME      NULL,
    [kc_apply_user1]  VARCHAR (10)  NULL,
    [kc_apply_date1]  DATETIME      NULL,
    [CreatePerson]    VARCHAR (10)  NULL,
    [CreateDate]      DATETIME      NULL,
    [kc_updt_user]    VARCHAR (10)  NULL,
    [kc_updt_date]    DATETIME      NULL,
    [kc_list_title]   VARCHAR (100) NULL,
    [kc_list_title1]  VARCHAR (100) NULL,
    [kc_list_url]     VARCHAR (100) NULL,
    CONSTRAINT [PK_kc_LinePushList] PRIMARY KEY CLUSTERED ([kc_list_no] ASC)
);

