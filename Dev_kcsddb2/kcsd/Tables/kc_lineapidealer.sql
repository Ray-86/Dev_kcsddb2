CREATE TABLE [kcsd].[kc_lineapidealer] (
    [kc_line_id]       VARCHAR (33)   NOT NULL,
    [kc_follow_date]   DATE           NULL,
    [kc_follow_status] VARCHAR (2)    NULL,
    [kc_display_name]  NVARCHAR (50)  NULL,
    [kc_picture_url]   VARCHAR (200)  NULL,
    [kc_status_msg]    NVARCHAR (800) NULL,
    [kc_agent_code]    VARCHAR (4)    NULL,
    [kc_branch_code]   VARCHAR (4)    NULL,
    [CreatePerson]     VARCHAR (20)   NULL,
    [CreateDate]       DATETIME       NULL,
    [kc_updt_user]     VARCHAR (20)   NULL,
    [kc_updt_date]     DATETIME       NULL,
    [kc_line_memo]     NVARCHAR (150) NULL,
    CONSTRAINT [PK_kc_lineapidealer] PRIMARY KEY CLUSTERED ([kc_line_id] ASC)
);

