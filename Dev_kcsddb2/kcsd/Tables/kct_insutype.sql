CREATE TABLE [kcsd].[kct_insutype] (
    [kc_insu_type]  VARCHAR (2)   NOT NULL,
    [kc_type_desc]  VARCHAR (20)  NOT NULL,
    [kc_type_desc2] VARCHAR (100) NULL,
    CONSTRAINT [PK_kct_insutype_1__20] PRIMARY KEY CLUSTERED ([kc_insu_type] ASC)
);

