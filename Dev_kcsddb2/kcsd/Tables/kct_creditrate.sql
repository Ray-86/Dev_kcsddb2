CREATE TABLE [kcsd].[kct_creditrate] (
    [kc_loan_perd] TINYINT      NOT NULL,
    [kc_cred_code] VARCHAR (20) NOT NULL,
    [kc_cred_rate] REAL         NOT NULL,
    CONSTRAINT [PK_kct_creditrate] PRIMARY KEY CLUSTERED ([kc_loan_perd] ASC, [kc_cred_code] ASC)
);

