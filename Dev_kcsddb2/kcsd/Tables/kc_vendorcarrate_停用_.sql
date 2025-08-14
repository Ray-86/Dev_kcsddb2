CREATE TABLE [kcsd].[kc_vendorcarrate(停用)] (
    [kc_vend_code] VARCHAR (4) NOT NULL,
    [kc_perd_no]   INT         NOT NULL,
    [kc_car_brand] VARCHAR (2) NOT NULL,
    [kc_insu_rate] FLOAT (53)  NOT NULL,
    [kc_proc_fee]  SMALLINT    NOT NULL,
    CONSTRAINT [PK__kc_vendorcarrate__2E06CDA9] PRIMARY KEY CLUSTERED ([kc_vend_code] ASC, [kc_car_brand] ASC, [kc_perd_no] ASC)
);

