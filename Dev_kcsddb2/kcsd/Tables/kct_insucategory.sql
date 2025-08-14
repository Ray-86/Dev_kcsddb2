CREATE TABLE [kcsd].[kct_insucategory] (
    [kc_insu_cate] VARCHAR (6)   NOT NULL,
    [kc_cate_desc] VARCHAR (100) NOT NULL,
    [kc_cate_rate] REAL          NULL,
    [kc_cate_fee]  INT           NULL,
    [status]       CHAR (1)      NOT NULL,
    [kc_insu_perd] CHAR (1)      NOT NULL,
    [mainrisks]    CHAR (1)      NOT NULL,
    CONSTRAINT [PK_kct_insucategory] PRIMARY KEY CLUSTERED ([kc_insu_cate] ASC)
);

