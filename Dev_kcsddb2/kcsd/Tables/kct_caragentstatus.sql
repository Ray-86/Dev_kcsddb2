CREATE TABLE [kcsd].[kct_caragentstatus] (
    [kc_agent_stat] VARCHAR (4)  NOT NULL,
    [kc_agent_desc] VARCHAR (50) NULL,
    CONSTRAINT [PK_kct_caragentstatus] PRIMARY KEY CLUSTERED ([kc_agent_stat] ASC)
);

