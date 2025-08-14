CREATE TABLE [kcsd].[kc_pushonhand_push] (
    [kc_push_date]     VARCHAR (6)   NULL,
    [kc_area_code]     VARCHAR (2)   NULL,
    [kc_prod_type]     VARCHAR (2)   NULL,
    [kc_pusher_code]   VARCHAR (4)   NULL,
    [kc_user_name]     NVARCHAR (10) NULL,
    [kc_push_cnt]      INT           NULL,
    [kc_over_amt]      INT           NULL,
    [kc_pay_cnt]       INT           NULL,
    [kc_pay_sum]       INT           NULL,
    [kc_pay_sum1]      INT           NULL,
    [kc_intr_sum]      INT           NULL,
    [kc_pay_amt]       INT           NULL,
    [kc_break_sum]     INT           NULL,
    [kc_close_cnt]     INT           NULL,
    [kc_scores_point]  FLOAT (53)    NULL,
    [kc_scores_point1] FLOAT (53)    NULL,
    [kc_pushover_sum]  INT           NULL,
    [kc_pushover_amt]  INT           NULL
);

