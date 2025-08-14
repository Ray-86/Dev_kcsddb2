CREATE TABLE [kcsd].[kc_hrattchangerecord] (
    [kc_record_no]     VARCHAR (10) NULL,
    [kc_clock_date]    DATETIME     NULL,
    [kc_clock_type]    VARCHAR (2)  NULL,
    [kc_executed_user] VARCHAR (4)  NULL,
    [CreatePerson]     VARCHAR (5)  NULL,
    [CreateDate]       DATETIME     NULL,
    [kc_clock_before]  DATETIME     NULL,
    [kc_source_before] VARCHAR (2)  NULL,
    [kc_clock_after]   DATETIME     NULL,
    [kc_source_after]  VARCHAR (2)  NULL,
    [kc_create_type]   VARCHAR (2)  NULL
);

