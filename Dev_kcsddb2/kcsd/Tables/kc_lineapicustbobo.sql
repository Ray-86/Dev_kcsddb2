CREATE TABLE [kcsd].[kc_lineapicustbobo] (
    [kc_line_id]       VARCHAR (33)   NOT NULL,
    [kc_follow_date]   DATE           NULL,
    [kc_follow_status] VARCHAR (2)    NULL,
    [kc_display_name]  NVARCHAR (50)  NULL,
    [kc_picture_url]   VARCHAR (300)  NULL,
    [kc_status_msg]    NVARCHAR (500) NULL,
    [kc_id_no]         VARCHAR (10)   NULL,
    [kc_cp_no]         VARCHAR (10)   NULL,
    [CreatePerson]     VARCHAR (20)   NULL,
    [CreateDate]       DATETIME       NULL,
    [kc_updt_user]     VARCHAR (20)   NULL,
    [kc_updt_date]     DATETIME       NULL,
    [kc_line_memo]     NVARCHAR (150) NULL,
    [kc_mobile_no]     VARCHAR (10)   NULL,
    [kc_quota_stat]    VARCHAR (1)    NULL,
    CONSTRAINT [PK_kc_lineapicustbobo] PRIMARY KEY CLUSTERED ([kc_line_id] ASC)
);

