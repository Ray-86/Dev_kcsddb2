CREATE TABLE [kcsd].[kc_vendor(停用)] (
    [kc_vend_code]  VARCHAR (4)   NOT NULL,
    [kc_vend_name]  VARCHAR (100) NOT NULL,
    [kc_vend_type]  VARCHAR (2)   NOT NULL,
    [kc_vend_addr]  VARCHAR (255) NULL,
    [kc_vend_phone] VARCHAR (100) NULL,
    [kc_vend_fax]   VARCHAR (100) NULL,
    [kc_emp_code]   VARCHAR (4)   NULL,
    [kc_buy_type]   VARCHAR (20)  NULL,
    [kc_totm_fee]   SMALLINT      NULL,
    [kc_totm_paper] SMALLINT      NULL,
    CONSTRAINT [PK___2__20] PRIMARY KEY CLUSTERED ([kc_vend_code] ASC)
);

