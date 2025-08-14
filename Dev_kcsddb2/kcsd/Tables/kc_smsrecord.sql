CREATE TABLE [kcsd].[kc_smsrecord] (
    [id]              INT           IDENTITY (1, 1) NOT NULL,
    [ip]              BIGINT        NOT NULL,
    [kc_cp_no]        VARCHAR (33)  NOT NULL,
    [kc_mobile_no]    VARCHAR (13)  NOT NULL,
    [kc_msg_id]       VARCHAR (20)  NULL,
    [kc_resp_stat]    VARCHAR (2)   NULL,
    [kc_resp_date]    DATETIME      NULL,
    [kc_dlv_time]     DATETIME      NULL,
    [kc_dlv_stat]     VARCHAR (100) NULL,
    [kc_dlv_date]     DATETIME      NULL,
    [CreateDate]      DATETIME      NOT NULL,
    [kc_item_no]      VARCHAR (20)  NULL,
    [kc_updt_date]    DATETIME      NULL,
    [kc_smscomp_type] VARCHAR (2)   NULL,
    [kc_msg_body]     VARCHAR (300) NULL,
    CONSTRAINT [PK_kc_smsrecord] PRIMARY KEY CLUSTERED ([id] ASC)
);

