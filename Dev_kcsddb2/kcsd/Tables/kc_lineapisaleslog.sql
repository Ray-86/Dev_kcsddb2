CREATE TABLE [kcsd].[kc_lineapisaleslog] (
    [ID]            INT           IDENTITY (1, 1) NOT NULL,
    [kc_line_id]    VARCHAR (33)  NULL,
    [kc_line_date]  DATE          NULL,
    [kc_line_event] VARCHAR (10)  NULL,
    [kc_line_type]  VARCHAR (10)  NULL,
    [kc_line_msg]   VARCHAR (500) NULL,
    [CreatePerson]  VARCHAR (20)  NULL,
    [CreateDate]    DATETIME      NULL,
    [kc_updt_user]  VARCHAR (20)  NULL,
    [kc_updt_date]  DATETIME      NULL,
    CONSTRAINT [PK_kc_lineapisaleslog] PRIMARY KEY CLUSTERED ([ID] ASC)
);

