CREATE TABLE [kcsd].[kct_court] (
    [kc_court_code] VARCHAR (10) NOT NULL,
    [kc_court_name] VARCHAR (40) NULL,
    CONSTRAINT [PK_kct_court] PRIMARY KEY CLUSTERED ([kc_court_code] ASC)
);

