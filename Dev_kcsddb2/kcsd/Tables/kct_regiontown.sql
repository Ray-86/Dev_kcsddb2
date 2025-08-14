CREATE TABLE [kcsd].[kct_regiontown] (
    [kc_town_code] VARCHAR (10) NOT NULL,
    [kc_town_name] VARCHAR (30) NULL,
    [kc_city_name] VARCHAR (30) NULL,
    [kc_regn_code] VARCHAR (5)  NULL,
    CONSTRAINT [PK_kct_regiontown] PRIMARY KEY CLUSTERED ([kc_town_code] ASC)
);

