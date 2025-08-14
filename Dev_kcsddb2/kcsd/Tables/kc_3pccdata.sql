CREATE TABLE [kcsd].[kc_3pccdata] (
    [kc_ext_code]    VARCHAR (2)   NOT NULL,
    [kc_region_code] VARCHAR (3)   NULL,
    [kc_server_ip]   VARCHAR (15)  NULL,
    [kc_server_port] VARCHAR (4)   NULL,
    [kc_data_memo]   VARCHAR (100) NULL,
    CONSTRAINT [PK_kc_3pccdata] PRIMARY KEY CLUSTERED ([kc_ext_code] ASC)
);

