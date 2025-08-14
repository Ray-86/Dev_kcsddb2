CREATE TABLE [kcsd].[kc_mvdistickets] (
    [kc_tick_no]     VARCHAR (20)  NOT NULL,
    [kc_uniform_no]  VARCHAR (18)  NULL,
    [kc_tick_type]   VARCHAR (2)   NULL,
    [kc_tick_date]   SMALLDATETIME NULL,
    [kc_licn_no]     VARCHAR (10)  NULL,
    [kc_tick_item]   VARCHAR (150) NULL,
    [kc_tick_local]  VARCHAR (50)  NULL,
    [kc_tick_target] VARCHAR (50)  NULL,
    [kc_tick_ref]    VARCHAR (50)  NULL,
    [kc_tick_rlocal] VARCHAR (50)  NULL,
    [kc_tick_rdate]  SMALLDATETIME NULL,
    [kc_tick_amt]    INT           NULL,
    [kc_updt_user]   VARCHAR (20)  NULL,
    [kc_updt_date]   SMALLDATETIME NULL,
    [kc_stat_date]   SMALLDATETIME NULL,
    CONSTRAINT [PK_kc_mvdistickets] PRIMARY KEY CLUSTERED ([kc_tick_no] ASC)
);

