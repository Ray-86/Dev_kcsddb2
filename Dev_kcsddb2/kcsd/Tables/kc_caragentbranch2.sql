CREATE TABLE [kcsd].[kc_caragentbranch2] (
    [kc_agent_code]  VARCHAR (30)  NOT NULL,
    [kc_branch_code] VARCHAR (4)   NOT NULL,
    [kc_branch_name] VARCHAR (50)  NULL,
    [IsEnable]       BIT           NULL,
    [CreatePerson]   VARCHAR (20)  NULL,
    [CreateDate]     DATETIME      NULL,
    [kc_updt_user]   VARCHAR (20)  NULL,
    [kc_updt_date]   SMALLDATETIME NULL,
    CONSTRAINT [PK_kc_caragentbranch2_1] PRIMARY KEY CLUSTERED ([kc_agent_code] ASC, [kc_branch_code] ASC)
);

