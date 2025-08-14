CREATE TABLE [kcsd].[kct_insutyped] (
    [kc_insu_type] VARCHAR (2) NOT NULL,
    [kc_insu_cate] VARCHAR (6) NOT NULL,
    [kc_insu_amt]  INT         NOT NULL,
    [kc_cate_fee]  INT         NOT NULL,
    CONSTRAINT [PK_kct_insutyped] PRIMARY KEY CLUSTERED ([kc_insu_type] ASC, [kc_insu_cate] ASC, [kc_insu_amt] ASC)
);

