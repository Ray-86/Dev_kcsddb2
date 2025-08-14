CREATE TABLE [kcsd].[kct_smstemplate] (
    [kc_sms_type]       NVARCHAR (2)   NOT NULL,
    [kc_sms_no]         INT            NOT NULL,
    [kc_sms_desc]       NVARCHAR (400) NOT NULL,
    [kc_sms_stat]       BIT            CONSTRAINT [DF_kct_smstemplate_kc_sms_stat] DEFAULT ((1)) NOT NULL,
    [kc_brand_code]     VARCHAR (2)    NULL,
    [kc_brand_item]     INT            NULL,
    [kc_smscomp_type]   NVARCHAR (2)   CONSTRAINT [DF_kct_smstemplate_kc_sms_stat1] DEFAULT ((1)) NULL,
    [kc_desclength_cnt] INT            NULL,
    [kc_chinese_text]   NVARCHAR (400) NULL,
    [kc_language_type]  VARCHAR (2)    NULL,
    [kc_date_type]      VARCHAR (2)    NULL,
    [kc_sms_stat_M0]    BIT            CONSTRAINT [DF_kct_smstemplate_kc_sms_stat1_1] DEFAULT ((1)) NOT NULL,
    [kc_sms_stat_M1]    BIT            CONSTRAINT [DF_kct_smstemplate_kc_sms_stat2] DEFAULT ((1)) NOT NULL,
    [kc_sms_stat_M2]    BIT            CONSTRAINT [DF_kct_smstemplate_kc_sms_stat21] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_kct_smstemplate] PRIMARY KEY CLUSTERED ([kc_sms_type] ASC, [kc_sms_no] ASC)
);

