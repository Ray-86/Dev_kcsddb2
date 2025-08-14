CREATE TABLE [kcsd].[kct_insurewdphone] (
    [kc_insu_type]  VARCHAR (2)   NOT NULL,
    [kc_insu_cate]  VARCHAR (6)   NOT NULL,
    [kc_rewd_phone] VARCHAR (100) NOT NULL,
    CONSTRAINT [PK_kct_insurewdphone] PRIMARY KEY CLUSTERED ([kc_insu_type] ASC, [kc_insu_cate] ASC)
);

