CREATE TABLE [kcsd].[kc_CpReportlistVerRecord] (
    [ID]              INT           IDENTITY (1, 1) NOT NULL,
    [kc_target_id]    INT           NULL,
    [IsEnable]        BIT           NULL,
    [VersionId]       VARCHAR (20)  NULL,
    [kc_apply_user]   VARCHAR (10)  NULL,
    [kc_apply_date]   DATETIME      NULL,
    [kc_apply_user2]  VARCHAR (10)  NULL,
    [kc_apply_date2]  DATETIME      NULL,
    [kc_version_memo] VARCHAR (400) NULL,
    [CreatePerson]    VARCHAR (10)  NULL,
    [CreateDate]      DATETIME      NULL,
    [kc_updt_user]    VARCHAR (10)  NULL,
    [kc_updt_date]    DATETIME      NULL,
    CONSTRAINT [PK_kc_CpReportlistVerRecord] PRIMARY KEY CLUSTERED ([ID] ASC)
);

