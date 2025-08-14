CREATE TABLE [kcsd].[kct_capital] (
    [kc_cap_code] VARCHAR (2)  NOT NULL,
    [kc_cap_desc] VARCHAR (30) NOT NULL,
    [kc_cap_bar]  VARCHAR (20) NULL,
    PRIMARY KEY CLUSTERED ([kc_cap_code] ASC)
);

