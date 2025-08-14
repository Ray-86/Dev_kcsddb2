CREATE TABLE [kcsd].[kc_inquirylog] (
    [kc_type]      VARCHAR (2)   NULL,
    [kc_userno]    VARCHAR (10)  NULL,
    [kc_inquiry]   VARCHAR (MAX) NULL,
    [kc_time]      DATETIME      NULL,
    [kc_ip_addr]   VARCHAR (20)  NULL,
    [kc_area_code] VARCHAR (2)   NULL
);

