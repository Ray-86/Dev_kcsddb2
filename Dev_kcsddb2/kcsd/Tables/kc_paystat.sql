CREATE TABLE [kcsd].[kc_paystat] (
    [kc_expt_date] SMALLDATETIME NOT NULL,
    [kc_expt_fee]  INT           NOT NULL,
    [kc_norm_pay]  INT           NOT NULL,
    [kc_delay_pay] INT           NOT NULL,
    [kc_no_pay]    INT           NOT NULL,
    [kc_updt_user] VARCHAR (10)  NULL,
    [kc_updt_date] SMALLDATETIME NULL,
    CONSTRAINT [PK_kc_paystat] PRIMARY KEY CLUSTERED ([kc_expt_date] ASC)
);

