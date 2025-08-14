CREATE TABLE [kcsd].[kc_period] (
    [kc_perd_year]  SMALLINT NOT NULL,
    [kc_perd_month] TINYINT  NOT NULL,
    [kc_perd_seq]   INT      NOT NULL,
    CONSTRAINT [PK___1__16] PRIMARY KEY CLUSTERED ([kc_perd_year] ASC, [kc_perd_month] ASC)
);

