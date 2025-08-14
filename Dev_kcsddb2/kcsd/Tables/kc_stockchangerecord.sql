CREATE TABLE [kcsd].[kc_stockchangerecord] (
    [kc_record_no]   VARCHAR (20) NOT NULL,
    [kc_stock_no]    VARCHAR (13) NULL,
    [kc_acc_before]  VARCHAR (3)  NULL,
    [kc_acc_after]   VARCHAR (3)  NULL,
    [kc_stock_price] FLOAT (53)   NULL,
    [kc_change_date] DATETIME     NULL,
    [kc_record_user] VARCHAR (10) NULL,
    [kc_record_date] DATETIME     NULL,
    [CreatePerson]   VARCHAR (10) NULL,
    [CreateDate]     DATETIME     NULL
);

