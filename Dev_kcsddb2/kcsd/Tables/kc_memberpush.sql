CREATE TABLE [kcsd].[kc_memberpush] (
    [kc_member_no]      VARCHAR (20)  NULL,
    [kc_item_no]        SMALLINT      NULL,
    [kc_area_code]      VARCHAR (2)   NULL,
    [kc_push_date]      SMALLDATETIME NULL,
    [kc_push_note]      VARCHAR (300) NULL,
    [kc_updt_user]      VARCHAR (10)  NULL,
    [kc_updt_date]      SMALLDATETIME NULL,
    [kc_sms_no]         INT           NULL,
    [kc_notice_no]      INT           NULL,
    [kc_push_link]      NVARCHAR (10) NULL,
    [kc_notice_link]    NVARCHAR (10) NULL,
    [kc_appt_date]      SMALLDATETIME NULL,
    [kc_effe_flag]      BIT           NULL,
    [kc_sms_flag]       VARCHAR (1)   NULL,
    [CreatePerson]      VARCHAR (10)  NULL,
    [CreateDate]        SMALLDATETIME NULL,
    [kc_pushdata_stasA] VARCHAR (10)  NULL,
    [kc_pushdata_stasB] VARCHAR (10)  NULL,
    [kc_pushdata_stasC] VARCHAR (10)  NULL
);

