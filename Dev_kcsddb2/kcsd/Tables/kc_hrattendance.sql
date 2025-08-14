CREATE TABLE [kcsd].[kc_hrattendance] (
    [UserID]          VARCHAR (4)  NULL,
    [kc_clock_date]   DATETIME     NULL,
    [kc_clock_type]   VARCHAR (2)  NULL,
    [kc_pos_lat]      VARCHAR (20) NULL,
    [kc_pos_lon]      VARCHAR (20) NULL,
    [CreatePerson]    VARCHAR (10) NULL,
    [CreateDate]      DATETIME     NULL,
    [kc_updt_user]    VARCHAR (10) NULL,
    [kc_updt_date]    DATETIME     NULL,
    [kc_clock_source] VARCHAR (2)  NULL
);

