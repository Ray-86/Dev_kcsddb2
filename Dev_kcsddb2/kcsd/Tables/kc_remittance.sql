CREATE TABLE [kcsd].[kc_remittance] (
    [kc_case_no]      VARCHAR (10)  NOT NULL,
    [kc_item_no]      INT           NOT NULL,
    [kc_buy_date]     DATETIME      NOT NULL,
    [kc_remit_amt]    INT           NULL,
    [kc_cfm_user]     VARCHAR (20)  NULL,
    [kc_cfm_date]     DATETIME      NULL,
    [kc_apply_user]   VARCHAR (20)  NULL,
    [kc_apply_date]   DATETIME      NULL,
    [kc_remit_user]   VARCHAR (20)  NULL,
    [kc_remit_date]   DATETIME      NULL,
    [kc_remit_memo]   VARCHAR (150) NULL,
    [CreatePerson]    VARCHAR (20)  NULL,
    [CreateDate]      DATETIME      NULL,
    [kc_updt_user]    VARCHAR (20)  NULL,
    [kc_updt_date]    DATETIME      NULL,
    [kc_sales_user]   VARCHAR (20)  NULL,
    [kc_sales_date]   DATETIME      NULL,
    [kc_autosms_flag] VARCHAR (1)   NULL,
    [kc_agent_flag]   VARCHAR (2)   NULL,
    [kc_agent_date]   DATETIME      NULL,
    CONSTRAINT [PK_kc_remittance] PRIMARY KEY CLUSTERED ([kc_case_no] ASC, [kc_item_no] ASC)
);

