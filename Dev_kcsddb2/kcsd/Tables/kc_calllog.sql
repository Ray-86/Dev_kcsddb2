CREATE TABLE [kcsd].[kc_calllog] (
    [kc_log_id]           INT           IDENTITY (1, 1) NOT NULL,
    [kc_call_date]        SMALLDATETIME NOT NULL,
    [kc_extension_number] VARCHAR (10)  NOT NULL,
    [kc_dial_number]      VARCHAR (10)  NOT NULL,
    [kc_case_no]          VARCHAR (20)  NULL,
    [IP]                  VARCHAR (20)  NULL,
    CONSTRAINT [PK_kc_calllog] PRIMARY KEY CLUSTERED ([kc_log_id] ASC)
);

