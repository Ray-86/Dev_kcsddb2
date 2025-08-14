CREATE TABLE [kcsd].[kc_blacklist] (
    [kc_id_no]         VARCHAR (10)  NOT NULL,
    [kc_cust_name]     VARCHAR (10)  NULL,
    [kc_black_reason]  VARCHAR (40)  NULL,
    [kc_black_reason2] VARCHAR (255) NULL,
    [kc_decline_flag]  VARCHAR (2)   NULL,
    [kc_updt_date]     SMALLDATETIME NULL,
    [kc_updt_user]     VARCHAR (10)  NULL,
    CONSTRAINT [PK_kc_blacklist] PRIMARY KEY CLUSTERED ([kc_id_no] ASC)
);


GO
CREATE NONCLUSTERED INDEX [i_kc_blacklist]
    ON [kcsd].[kc_blacklist]([kc_cust_name] ASC);

