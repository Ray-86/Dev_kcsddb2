CREATE TABLE [kcsd].[kc_lineapitesttarotapilog] (
    [ID]             INT           IDENTITY (1, 1) NOT NULL,
    [kc_question_id] INT           NULL,
    [kc_api_date]    DATETIME      NULL,
    [kc_api_key]     VARCHAR (50)  NULL,
    [kc_line_id]     VARCHAR (33)  NULL,
    [kc_question]    VARCHAR (MAX) NULL,
    [kc_answer]      VARCHAR (MAX) NULL,
    CONSTRAINT [PK_kc_lineapitesttarotapilog] PRIMARY KEY CLUSTERED ([ID] ASC)
);

