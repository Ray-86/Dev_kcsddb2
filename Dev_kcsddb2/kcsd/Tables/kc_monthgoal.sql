CREATE TABLE [kcsd].[kc_monthgoal] (
    [kc_perd_year]  SMALLINT    NOT NULL,
    [kc_perd_month] TINYINT     NOT NULL,
    [kc_comp_char]  VARCHAR (2) NOT NULL,
    [kc_sales_code] VARCHAR (6) NOT NULL,
    [kc_expt_cnt]   INT         NOT NULL,
    [kc_expt_fee]   INT         NOT NULL,
    [kc_real_cnt]   INT         NOT NULL,
    [kc_real_fee]   INT         NOT NULL,
    CONSTRAINT [PK_kc_monthgoal_1__23] PRIMARY KEY CLUSTERED ([kc_perd_year] ASC, [kc_perd_month] ASC, [kc_comp_char] ASC, [kc_sales_code] ASC)
);

