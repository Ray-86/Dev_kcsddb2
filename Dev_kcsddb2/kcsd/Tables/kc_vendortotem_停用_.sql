CREATE TABLE [kcsd].[kc_vendortotem(停用)] (
    [kc_vend_code]  VARCHAR (4) NOT NULL,
    [kc_perd_no]    INT         NOT NULL,
    [kc_totm_fee]   SMALLINT    NOT NULL,
    [kc_totm_paper] SMALLINT    NOT NULL,
    CONSTRAINT [PK_kc_vendortotem_1__14] PRIMARY KEY CLUSTERED ([kc_vend_code] ASC, [kc_perd_no] ASC)
);

