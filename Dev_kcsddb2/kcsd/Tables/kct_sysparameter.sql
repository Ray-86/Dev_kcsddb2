CREATE TABLE [kcsd].[kct_sysparameter] (
    [kc_issu_code] VARCHAR (6) NOT NULL,
    [kc_lock_fee]  INT         NOT NULL,
    [kc_lock_fee2] INT         NOT NULL,
    CONSTRAINT [PK_kct_sysparameter] PRIMARY KEY CLUSTERED ([kc_issu_code] ASC)
);

