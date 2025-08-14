CREATE TABLE [kcsd].[kc_cpviplist] (
    [UserSeq]        VARCHAR (4) NOT NULL,
    [kc_area_code]   VARCHAR (2) NOT NULL,
    [kc_vip_type]    VARCHAR (2) NULL,
    [kc_prod_stat01] BIT         NULL,
    [kc_prod_stat04] BIT         NULL,
    [kc_prod_stat10] BIT         NULL,
    [kc_prod_stat11] BIT         NULL,
    [kc_prod_stat06] BIT         NULL,
    [kc_prod_stat07] BIT         NULL,
    [kc_prod_stat13] BIT         NULL,
    [kc_prod_stat14] BIT         NULL,
    [kc_prod_stat16] BIT         NULL,
    [kc_prod_stat17] BIT         NULL,
    [kc_prod_stat18] BIT         NULL,
    CONSTRAINT [PK_kc_cpviplist] PRIMARY KEY CLUSTERED ([UserSeq] ASC, [kc_area_code] ASC)
);

