CREATE TABLE [kcsd].[kc_creditmemo] (
    [kc_cp_no]           VARCHAR (10)  NOT NULL,
    [kc_item_no]         SMALLINT      NOT NULL,
    [kc_credit_memo]     VARCHAR (500) NULL,
    [kc_notice_user]     VARCHAR (10)  NULL,
    [kc_notice_date]     DATETIME      NULL,
    [kc_notice_flag]     VARCHAR (1)   NULL,
    [CreatePerson]       VARCHAR (10)  NULL,
    [CreateDate]         DATETIME      NULL,
    [kc_updt_date]       SMALLDATETIME NULL,
    [kc_updt_user]       VARCHAR (10)  NULL,
    [kc_accept_user]     VARCHAR (10)  NULL,
    [kc_accept_date]     DATETIME      NULL,
    [kc_creditmemo_type] VARCHAR (2)   NULL,
    [kc_sms_flag]        VARCHAR (1)   NULL,
    [kc_list_type]       VARCHAR (10)  NULL,
    CONSTRAINT [PK_kc_creditmemo] PRIMARY KEY CLUSTERED ([kc_cp_no] ASC, [kc_item_no] ASC)
);

