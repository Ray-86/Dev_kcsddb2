CREATE TABLE [kcsd].[kc_stockdata] (
    [kc_stock_no]     VARCHAR (13)  NOT NULL,
    [kc_acc_no]       VARCHAR (3)   NULL,
    [kc_source_type]  VARCHAR (2)   NULL,
    [kc_stock_number] INT           NULL,
    [kc_stock_memo]   VARCHAR (100) NULL,
    [kc_stock_date]   DATETIME      NULL,
    [kc_effect_date]  DATETIME      NULL,
    [CreatePerson]    VARCHAR (10)  NULL,
    [CreateDate]      DATETIME      NULL,
    CONSTRAINT [PK_kc_stockdata] PRIMARY KEY CLUSTERED ([kc_stock_no] ASC)
);

