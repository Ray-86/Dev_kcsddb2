CREATE TABLE [kcsd].[kc_autocall] (
    [kc_call_id]          INT           IDENTITY (1, 1) NOT NULL,
    [kc_call_type]        NVARCHAR (10) NOT NULL,
    [kc_call_date]        SMALLDATETIME NOT NULL,
    [kc_case_no]          VARCHAR (10)  NOT NULL,
    [kc_mobile_no]        VARCHAR (20)  NOT NULL,
    [kc_acquisition_time] SMALLDATETIME NULL,
    [kc_call_status]      VARCHAR (10)  NULL,
    [kc_callout_time]     DATETIME      NULL,
    [kc_talk_time]        INT           NULL,
    [kc_call_count]       INT           NULL,
    CONSTRAINT [PK_kc_autocall] PRIMARY KEY CLUSTERED ([kc_call_id] ASC)
);

