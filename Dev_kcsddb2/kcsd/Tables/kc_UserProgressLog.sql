CREATE TABLE [kcsd].[kc_UserProgressLog] (
    [ID]             INT           IDENTITY (1, 1) NOT NULL,
    [kc_id_no]       VARCHAR (10)  NULL,
    [kc_cp_no]       VARCHAR (10)  NULL,
    [kc_source_type] VARCHAR (50)  NULL,
    [CreatePerson]   VARCHAR (10)  NULL,
    [CreateDate]     DATETIME      NULL,
    [kc_updt_user]   VARCHAR (10)  NULL,
    [kc_updt_date]   SMALLDATETIME NULL,
    [kc_step_state]  INT           NULL,
    [kc_finish_bool] BIT           NULL,
    CONSTRAINT [PK_kc_UserProgressLog] PRIMARY KEY CLUSTERED ([ID] ASC)
);

