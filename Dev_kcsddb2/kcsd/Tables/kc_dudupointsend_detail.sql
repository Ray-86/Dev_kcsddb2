CREATE TABLE [kcsd].[kc_dudupointsend_detail] (
    [ID]                 INT           IDENTITY (1, 1) NOT NULL,
    [kc_list_no]         VARCHAR (10)  NULL,
    [kc_member_no]       VARCHAR (11)  NULL,
    [kc_dudupoint_fee]   INT           NULL,
    [kc_expiration_date] DATETIME      NULL,
    [IsEnable]           BIT           NULL,
    [CreatePerson]       VARCHAR (10)  NULL,
    [CreateDate]         DATETIME      NULL,
    [kc_updt_user]       VARCHAR (10)  NULL,
    [kc_updt_date]       DATETIME      NULL,
    [kc_segment]         INT           NULL,
    [kc_dudupoint_stat]  VARCHAR (1)   NULL,
    [kc_apply_user]      VARCHAR (10)  NULL,
    [kc_apply_date]      DATETIME      NULL,
    [kc_approve_user]    VARCHAR (10)  NULL,
    [kc_approve_date]    DATETIME      NULL,
    [kc_cancel_user]     VARCHAR (10)  NULL,
    [kc_cancel_date]     DATETIME      NULL,
    [kc_dudupoint_memo]  VARCHAR (100) NULL,
    CONSTRAINT [PK_kc_dudupointsend_detail] PRIMARY KEY CLUSTERED ([ID] ASC)
);

