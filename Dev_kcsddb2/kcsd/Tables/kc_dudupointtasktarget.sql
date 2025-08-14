CREATE TABLE [kcsd].[kc_dudupointtasktarget] (
    [ID]           INT           IDENTITY (1, 1) NOT NULL,
    [kc_task_no]   VARCHAR (4)   NULL,
    [kc_task_desc] VARCHAR (50)  NULL,
    [kc_task_memo] VARCHAR (100) NULL,
    [kc_task_stat] VARCHAR (1)   NULL,
    [CreatePerson] VARCHAR (10)  NULL,
    [CreateDate]   DATETIME      NULL,
    [kc_updt_user] VARCHAR (10)  NULL,
    [kc_updt_date] DATETIME      NULL,
    CONSTRAINT [PK_kc_dudupointtasktarget] PRIMARY KEY CLUSTERED ([ID] ASC)
);

