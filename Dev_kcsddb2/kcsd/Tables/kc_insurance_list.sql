CREATE TABLE [kcsd].[kc_insurance_list] (
    [kc_cp_no]     VARCHAR (10)  NOT NULL,
    [kc_case_no]   VARCHAR (10)  NULL,
    [kc_insu_cate] VARCHAR (6)   NOT NULL,
    [kc_insu_amt]  INT           NULL,
    [kc_insu_fee]  INT           NULL,
    [kc_insu_type] VARCHAR (2)   NULL,
    [kc_item_no]   SMALLINT      NULL,
    [kc_updt_date] SMALLDATETIME NULL,
    [kc_updt_user] VARCHAR (10)  NULL,
    CONSTRAINT [PK_kc_insurance_list] PRIMARY KEY CLUSTERED ([kc_cp_no] ASC, [kc_insu_cate] ASC)
);


GO
CREATE NONCLUSTERED INDEX [i_kc_insurance_list]
    ON [kcsd].[kc_insurance_list]([kc_case_no] ASC, [kc_insu_cate] ASC);

