CREATE TABLE [kcsd].[kct_traffictickettype] (
    [kc_tick_type] VARCHAR (4)   NOT NULL,
    [kc_tick_desc] VARCHAR (100) NOT NULL,
    [kc_proc_fee]  INT           NULL,
    CONSTRAINT [PK_kct_traffictickettype] PRIMARY KEY CLUSTERED ([kc_tick_type] ASC)
);

