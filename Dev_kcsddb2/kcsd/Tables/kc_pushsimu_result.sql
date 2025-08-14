CREATE TABLE [kcsd].[kc_pushsimu_result] (
    [kc_case_no]    VARCHAR (10) NOT NULL,
    [kc_pusher_old] VARCHAR (6)  NULL,
    [kc_pusher_new] VARCHAR (6)  NULL,
    [kc_over_amt]   INT          NULL,
    CONSTRAINT [PK_kc_pushsimu_result] PRIMARY KEY CLUSTERED ([kc_case_no] ASC)
);

