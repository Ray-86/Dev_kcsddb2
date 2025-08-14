CREATE TABLE [kcsd].[kct_area] (
    [kc_area_code]    VARCHAR (2)   NOT NULL,
    [kc_area_desc]    VARCHAR (30)  NOT NULL,
    [kc_host_name]    VARCHAR (10)  NULL,
    [kc_area_addr]    NVARCHAR (50) NULL,
    [kc_area_phone]   NVARCHAR (15) NULL,
    [kc_default_bank] VARCHAR (2)   NULL,
    CONSTRAINT [PK_kct_area] PRIMARY KEY CLUSTERED ([kc_area_code] ASC)
);

