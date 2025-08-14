CREATE TABLE [kcsd].[kc_insurance_list_insu] (
    [kc_case_no]   VARCHAR (10)  NOT NULL,
    [kc_insu_cate] VARCHAR (6)   NOT NULL,
    [kc_item_no]   INT           NOT NULL,
    [kc_insu_amt]  INT           NOT NULL,
    [kc_insu_fee]  INT           NOT NULL,
    [kc_insu_type] VARCHAR (2)   NULL,
    [kc_updt_user] VARCHAR (20)  NULL,
    [kc_updt_date] SMALLDATETIME NULL,
    CONSTRAINT [PK_kc_insurance_list_insu] PRIMARY KEY CLUSTERED ([kc_case_no] ASC, [kc_insu_cate] ASC, [kc_item_no] ASC)
);

