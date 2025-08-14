CREATE TABLE [kcsd].[kc_otherpayment] (
    [kc_case_no]     VARCHAR (10)  NOT NULL,
    [kc_area_code]   VARCHAR (2)   NOT NULL,
    [kc_pay_date]    DATETIME      NULL,
    [kc_pay_type]    VARCHAR (1)   NULL,
    [kc_pay_fee]     INT           NULL,
    [kc_intr_fee]    INT           NULL,
    [kc_oper_code]   VARCHAR (6)   NULL,
    [kc_updt_user]   VARCHAR (10)  NULL,
    [kc_updt_date]   SMALLDATETIME NULL,
    [kc_offset_type] VARCHAR (2)   NULL,
    [kc_coll_type]   VARCHAR (2)   NULL,
    [kc_item_no]     SMALLINT      NULL,
    [CreatePerson]   VARCHAR (20)  NULL,
    [CreateDate]     DATETIME      NULL
);


GO
CREATE NONCLUSTERED INDEX [i_kc_otherpayment_1]
    ON [kcsd].[kc_otherpayment]([kc_case_no] ASC, [kc_area_code] ASC, [kc_item_no] ASC);

