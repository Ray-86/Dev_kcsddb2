CREATE TABLE [kcsd].[kc_itlist] (
    [kc_list_no]          VARCHAR (10)  NOT NULL,
    [kc_list_date]        DATETIME      NULL,
    [kc_list_user]        VARCHAR (10)  NULL,
    [kc_apply_department] VARCHAR (10)  NULL,
    [kc_apply_type]       VARCHAR (2)   NULL,
    [kc_deadline_date]    DATETIME      NULL,
    [kc_system_type]      VARCHAR (2)   NULL,
    [kc_list_main]        VARCHAR (100) NULL,
    [kc_apply_user]       VARCHAR (10)  NULL,
    [kc_apply_date]       DATETIME      NULL,
    [kc_itfinish_user]    VARCHAR (10)  NULL,
    [kc_itfinish_date]    DATETIME      NULL,
    [kc_test_user]        VARCHAR (10)  NULL,
    [kc_test_date]        DATETIME      NULL,
    [kc_online_user]      VARCHAR (10)  NULL,
    [kc_online_date]      DATETIME      NULL,
    [kc_list_memo]        VARCHAR (100) NULL,
    [kc_cancel_user]      VARCHAR (10)  NULL,
    [kc_cancel_date]      DATETIME      NULL,
    [kc_type]             VARCHAR (2)   NULL,
    CONSTRAINT [PK_kc_itlist] PRIMARY KEY CLUSTERED ([kc_list_no] ASC)
);

