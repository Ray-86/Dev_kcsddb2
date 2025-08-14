CREATE TABLE [kcsd].[kc_marketer] (
    [kc_case_no]        VARCHAR (10)  NOT NULL,
    [kc_strt_date]      SMALLDATETIME NOT NULL,
    [kc_stop_date]      SMALLDATETIME NULL,
    [kc_marketer_code]  VARCHAR (10)  NOT NULL,
    [kc_marketing_type] VARCHAR (2)   NULL,
    [kc_marketing_user] VARCHAR (4)   NULL,
    [kc_marketing_date] DATETIME      NULL,
    [kc_marketing_memo] VARCHAR (100) NULL,
    [kc_updt_user]      VARCHAR (10)  NULL,
    [kc_updt_date]      SMALLDATETIME NULL,
    [kc_item_no]        INT           IDENTITY (1, 1) NOT NULL
);

