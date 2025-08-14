CREATE TABLE [kcsd].[kc_pushassign] (
    [kc_case_no]     VARCHAR (10)  NOT NULL,
    [kc_strt_date]   SMALLDATETIME NOT NULL,
    [kc_stop_date]   SMALLDATETIME NULL,
    [kc_pusher_code] VARCHAR (10)  NOT NULL,
    [kc_updt_user]   VARCHAR (10)  NULL,
    [kc_updt_date]   SMALLDATETIME NULL,
    [kc_delay_code]  VARCHAR (4)   NULL,
    [kc_pusher_amt]  INT           NULL,
    [kc_break_amt]   INT           NULL,
    [kc_expt_date]   SMALLDATETIME NULL,
    [kc_area_code]   VARCHAR (2)   NULL,
    [CreatePerson]   VARCHAR (20)  NULL,
    [CreateDate]     DATETIME      NULL,
    CONSTRAINT [PK_kc_pushassign] PRIMARY KEY CLUSTERED ([kc_case_no] ASC, [kc_strt_date] ASC, [kc_pusher_code] ASC)
);


GO
CREATE NONCLUSTERED INDEX [i_kc_pushassign]
    ON [kcsd].[kc_pushassign]([kc_strt_date] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_pushassign_2]
    ON [kcsd].[kc_pushassign]([kc_stop_date] ASC);

