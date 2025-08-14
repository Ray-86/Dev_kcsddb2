CREATE TABLE [kcsd].[kc_feescoll] (
    [kc_case_no]    VARCHAR (10)  NOT NULL,
    [kc_area_code]  VARCHAR (2)   NOT NULL,
    [kc_item_no]    SMALLINT      NOT NULL,
    [kc_input_date] DATETIME      NULL,
    [kc_coll_type]  VARCHAR (2)   NULL,
    [kc_finsu_perd] SMALLINT      NULL,
    [kc_coll_date]  DATETIME      NULL,
    [kc_coll_fee]   INT           NULL,
    [kc_pay_date]   DATETIME      NULL,
    [kc_pay_fee]    INT           NULL,
    [kc_pay_type]   VARCHAR (2)   NULL,
    [kc_updt_user]  VARCHAR (10)  NULL,
    [kc_updt_date]  SMALLDATETIME NULL,
    CONSTRAINT [PK_kc_feescoll] PRIMARY KEY CLUSTERED ([kc_case_no] ASC, [kc_area_code] ASC, [kc_item_no] ASC)
);

