CREATE TABLE [kcsd].[kc_caragentalliance] (
    [kc_alliance_code] VARCHAR (4)   NOT NULL,
    [kc_agent_code]    VARCHAR (4)   NOT NULL,
    [kc_alliance_memo] VARCHAR (150) NULL,
    [CreatePerson]     VARCHAR (20)  NULL,
    [CreateDate]       DATETIME      NULL,
    [kc_updt_user]     VARCHAR (20)  NULL,
    [kc_updt_date]     SMALLDATETIME NULL,
    CONSTRAINT [PK_kc_caragentalliance] PRIMARY KEY CLUSTERED ([kc_alliance_code] ASC, [kc_agent_code] ASC)
);

