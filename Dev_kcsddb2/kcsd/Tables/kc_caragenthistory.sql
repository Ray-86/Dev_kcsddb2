CREATE TABLE [kcsd].[kc_caragenthistory] (
    [kc_agent_code] VARCHAR (10)   NOT NULL,
    [kc_data_type]  VARCHAR (30)   NOT NULL,
    [kc_data_data]  NVARCHAR (200) NULL,
    [kc_updt_user]  VARCHAR (10)   NULL,
    [kc_updt_date]  DATETIME       NULL
);

