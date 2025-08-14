CREATE TABLE [kcsd].[kc_merchanttrade_] (
    [kc_merchant_id]  VARCHAR (4)   NOT NULL,
    [kc_order_no]     VARCHAR (30)  NOT NULL,
    [kc_item_desc]    VARCHAR (50)  NOT NULL,
    [kc_loan_amt]     INT           NOT NULL,
    [kc_loan_perd]    INT           NOT NULL,
    [kc_perd_fee]     INT           NOT NULL,
    [kc_time_stamp]   VARCHAR (30)  NOT NULL,
    [kc_client_ip]    BIGINT        NOT NULL,
    [kc_trade_status] VARCHAR (1)   NOT NULL,
    [kc_cp_no]        VARCHAR (10)  NULL,
    [CreatePerson]    VARCHAR (10)  NOT NULL,
    [CreateDate]      DATETIME      NOT NULL,
    [kc_updt_user]    VARCHAR (10)  NOT NULL,
    [kc_updt_date]    SMALLDATETIME NOT NULL,
    CONSTRAINT [PK_kc_merchanttrade] PRIMARY KEY CLUSTERED ([kc_merchant_id] ASC, [kc_order_no] ASC)
);

