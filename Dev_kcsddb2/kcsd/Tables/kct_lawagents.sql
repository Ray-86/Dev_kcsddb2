CREATE TABLE [kcsd].[kct_lawagents] (
    [kc_lawagents_code] VARCHAR (2)   NOT NULL,
    [kc_lawagents_name] NVARCHAR (20) NOT NULL,
    [status]            CHAR (1)      NOT NULL,
    CONSTRAINT [PK_kct_lawagents] PRIMARY KEY CLUSTERED ([kc_lawagents_code] ASC)
);

