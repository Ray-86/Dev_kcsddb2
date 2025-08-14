CREATE TABLE [kcsd].[kct_regioncity] (
    [kc_city_code] VARCHAR (10) NOT NULL,
    [kc_city_name] VARCHAR (30) NULL,
    CONSTRAINT [PK_kct_regioncity] PRIMARY KEY CLUSTERED ([kc_city_code] ASC)
);

