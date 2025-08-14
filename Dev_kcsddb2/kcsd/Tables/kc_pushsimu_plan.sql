CREATE TABLE [kcsd].[kc_pushsimu_plan] (
    [kc_pusher_code] VARCHAR (6) NOT NULL,
    [kc_pusher_rate] INT         NOT NULL,
    [kc_case_qty]    INT         NULL,
    [kc_over_amt]    INT         NULL,
    [kc_push_sort]   VARCHAR (4) NULL,
    CONSTRAINT [PK_kc_pushsimu_plan] PRIMARY KEY CLUSTERED ([kc_pusher_code] ASC)
);

