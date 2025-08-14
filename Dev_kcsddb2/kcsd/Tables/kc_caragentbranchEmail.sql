CREATE TABLE [kcsd].[kc_caragentbranchEmail] (
    [kc_agent_code] VARCHAR (30)  NOT NULL,
    [kc_email_no]   VARCHAR (100) NOT NULL,
    [IsEnable]      BIT           NULL,
    [CreatePerson]  VARCHAR (20)  NULL,
    [CreateDate]    DATETIME      NULL,
    [kc_updt_user]  VARCHAR (20)  NULL,
    [kc_updt_date]  SMALLDATETIME NULL,
    CONSTRAINT [PK_kc_caragentbranchEmail] PRIMARY KEY CLUSTERED ([kc_agent_code] ASC, [kc_email_no] ASC)
);

