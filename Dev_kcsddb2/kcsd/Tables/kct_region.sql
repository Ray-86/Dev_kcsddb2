CREATE TABLE [kcsd].[kct_region] (
    [kc_regn_code] VARCHAR (5)  NOT NULL,
    [kc_regn_name] VARCHAR (40) NOT NULL,
    [kc_regn_cate] VARCHAR (30) NULL,
    CONSTRAINT [PK_kct_region_1__25] PRIMARY KEY CLUSTERED ([kc_regn_code] ASC)
);

