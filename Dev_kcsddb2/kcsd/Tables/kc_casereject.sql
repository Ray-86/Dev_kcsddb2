CREATE TABLE [kcsd].[kc_casereject] (
    [kc_cp_no]      VARCHAR (10)  NOT NULL,
    [kc_item_no]    INT           NOT NULL,
    [kc_rej_date]   DATETIME      NOT NULL,
    [kc_cust_nameu] NVARCHAR (60) NOT NULL,
    [kc_rej_note]   VARCHAR (200) NOT NULL,
    [CreatePerson]  VARCHAR (20)  NULL,
    [CreateDate]    DATETIME      NULL,
    [kc_updt_user]  VARCHAR (20)  NULL,
    [kc_updt_date]  DATETIME      NULL,
    [kc_sales_code] VARCHAR (6)   NULL,
    [kc_comp_code]  VARCHAR (4)   NULL,
    CONSTRAINT [PK_kc_casereject] PRIMARY KEY CLUSTERED ([kc_cp_no] ASC, [kc_item_no] ASC)
);

