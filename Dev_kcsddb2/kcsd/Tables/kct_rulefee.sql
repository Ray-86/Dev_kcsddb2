CREATE TABLE [kcsd].[kct_rulefee] (
    [kc_car_cc]   SMALLINT NOT NULL,
    [kc_rule_fee] INT      NOT NULL,
    CONSTRAINT [PK_kct_rulefee] PRIMARY KEY CLUSTERED ([kc_car_cc] ASC)
);

