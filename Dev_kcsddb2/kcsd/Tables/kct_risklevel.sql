CREATE TABLE [kcsd].[kct_risklevel] (
    [kc_prod_type]  VARCHAR (2)  NOT NULL,
    [kc_risk_level] VARCHAR (1)  NOT NULL,
    [kc_risk_lower] INT          NOT NULL,
    [kc_risk_upper] INT          NOT NULL,
    [kc_risk_memo]  VARCHAR (10) NOT NULL,
    [CreatePerson]  VARCHAR (20) NULL,
    [CreateDate]    DATETIME     NULL,
    [kc_updt_user]  VARCHAR (20) NULL,
    [kc_updt_date]  DATETIME     NULL,
    CONSTRAINT [PK_kc_risklevel] PRIMARY KEY CLUSTERED ([kc_prod_type] ASC, [kc_risk_level] ASC)
);

