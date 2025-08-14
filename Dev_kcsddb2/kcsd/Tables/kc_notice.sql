CREATE TABLE [kcsd].[kc_notice] (
    [kc_case_no]      VARCHAR (10)   NOT NULL,
    [kc_item_no]      INT            NOT NULL,
    [kc_area_code]    VARCHAR (2)    NOT NULL,
    [kc_notice_link]  VARCHAR (50)   NULL,
    [kc_notice_user]  VARCHAR (20)   NULL,
    [kc_caution_user] VARCHAR (20)   NULL,
    [kc_finish_user]  VARCHAR (20)   NULL,
    [kc_notice_time]  DATETIME       NULL,
    [kc_finish_time]  DATETIME       NULL,
    [kc_notice_note]  NVARCHAR (150) NULL,
    CONSTRAINT [PK_kc_notice] PRIMARY KEY CLUSTERED ([kc_case_no] ASC, [kc_item_no] ASC)
);

