CREATE TABLE [kcsd].[kc_caragentscore] (
    [kc_perd_code]  VARCHAR (20) NOT NULL,
    [kc_agent_code] VARCHAR (30) NOT NULL,
    [kc_sale_qty]   SMALLINT     NOT NULL,
    [kc_sale_grade] VARCHAR (10) NULL,
    CONSTRAINT [PK_kc_caragentscore] PRIMARY KEY CLUSTERED ([kc_perd_code] ASC, [kc_agent_code] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [i_kc_caragentscore]
    ON [kcsd].[kc_caragentscore]([kc_agent_code] ASC, [kc_perd_code] ASC);

