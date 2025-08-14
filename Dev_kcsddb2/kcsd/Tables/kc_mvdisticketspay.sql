CREATE TABLE [kcsd].[kc_mvdisticketspay] (
    [kc_tick_no]    VARCHAR (20)  NOT NULL,
    [kc_uniform_no] VARCHAR (20)  NOT NULL,
    [kc_pay_date]   SMALLDATETIME NOT NULL,
    [kc_tick_item]  VARCHAR (200) NOT NULL,
    [kc_pay_type]   VARCHAR (50)  NOT NULL,
    [kc_pay_amt]    INT           NOT NULL,
    [kc_updt_user]  VARCHAR (10)  NOT NULL,
    [kc_updt_date]  SMALLDATETIME NOT NULL,
    PRIMARY KEY CLUSTERED ([kc_tick_no] ASC)
);

