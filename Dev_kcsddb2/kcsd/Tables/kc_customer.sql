CREATE TABLE [kcsd].[kc_customer] (
    [kc_cust_name] NVARCHAR (60) NOT NULL,
    [kc_id_no]     VARCHAR (20)  NULL,
    [kc_cust_role] VARCHAR (10)  NOT NULL,
    [kc_area_code] VARCHAR (2)   NOT NULL,
    [kc_updt_user] VARCHAR (50)  NULL,
    [kc_updt_date] SMALLDATETIME NULL
);


GO
CREATE NONCLUSTERED INDEX [i_kc_customer]
    ON [kcsd].[kc_customer]([kc_cust_name] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customer_2]
    ON [kcsd].[kc_customer]([kc_id_no] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customer_3]
    ON [kcsd].[kc_customer]([kc_area_code] ASC);

