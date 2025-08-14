CREATE TABLE [kcsd].[kct_lawrate] (
    [kc_rate_code] VARCHAR (2) NOT NULL,
    [kc_rate_name] VARCHAR (4) NOT NULL,
    [status]       CHAR (1)    NOT NULL,
    CONSTRAINT [PK_kct_lawrate] PRIMARY KEY CLUSTERED ([kc_rate_code] ASC)
);

