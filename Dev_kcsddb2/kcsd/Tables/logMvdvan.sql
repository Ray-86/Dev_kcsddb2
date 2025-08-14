CREATE TABLE [kcsd].[logMvdvan] (
    [ID]         INT           IDENTITY (1, 1) NOT NULL,
    [UserCode]   VARCHAR (20)  NULL,
    [KeyWord]    VARCHAR (200) NULL,
    [Datetime]   DATETIME      NULL,
    [Host]       VARCHAR (15)  NULL,
    [kc_case_no] VARCHAR (10)  NULL,
    CONSTRAINT [PK_log_mvdvan] PRIMARY KEY CLUSTERED ([ID] ASC)
);

