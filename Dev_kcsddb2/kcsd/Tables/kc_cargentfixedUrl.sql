CREATE TABLE [kcsd].[kc_cargentfixedUrl] (
    [ID]            INT           IDENTITY (1, 1) NOT NULL,
    [kc_agent_code] VARCHAR (4)   NULL,
    [kc_prod_type]  VARCHAR (2)   NULL,
    [kc_fixedurl]   VARCHAR (200) NULL,
    [kc_prod_text]  VARCHAR (50)  NULL,
    [kc_loan_type]  VARCHAR (4)   NULL,
    [IsEnable]      BIT           NULL,
    [CreatePerson]  VARCHAR (10)  NULL,
    [CreateDate]    DATETIME      NULL,
    [kc_updt_user]  VARCHAR (10)  NULL,
    [kc_updt_date]  DATETIME      NULL,
    CONSTRAINT [PK_kc_cargentfixedUrl] PRIMARY KEY CLUSTERED ([ID] ASC)
);

