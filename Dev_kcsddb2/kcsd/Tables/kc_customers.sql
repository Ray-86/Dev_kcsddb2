CREATE TABLE [kcsd].[kc_customers] (
    [kc_case_no]    VARCHAR (10)  NOT NULL,
    [kc_cust_type]  SMALLINT      NOT NULL,
    [kc_cust_cnt]   SMALLINT      NOT NULL,
    [kc_id_no]      VARCHAR (10)  NOT NULL,
    [kc_cust_nameu] NVARCHAR (60) NOT NULL,
    [kc_updt_user]  VARCHAR (50)  NOT NULL,
    [kc_updt_date]  DATETIME      NOT NULL,
    CONSTRAINT [PK_kc_customers] PRIMARY KEY CLUSTERED ([kc_case_no] ASC, [kc_cust_type] ASC, [kc_cust_cnt] ASC)
);


GO
CREATE NONCLUSTERED INDEX [i_kc_customers_1]
    ON [kcsd].[kc_customers]([kc_id_no] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customers_2]
    ON [kcsd].[kc_customers]([kc_cust_nameu] ASC);

