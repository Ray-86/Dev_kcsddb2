CREATE TABLE [kcsd].[kct_producttype] (
    [kc_prod_type] VARCHAR (4)   NOT NULL,
    [kc_prod_desc] VARCHAR (100) NOT NULL,
    CONSTRAINT [PK_kct_producttype] PRIMARY KEY CLUSTERED ([kc_prod_type] ASC)
);

