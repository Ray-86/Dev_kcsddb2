CREATE TABLE [kcsd].[kc_customerold(停用)] (
    [kc_case_no]    VARCHAR (10) NOT NULL,
    [kc_cust_name]  VARCHAR (10) NOT NULL,
    [kc_id_no]      VARCHAR (10) NULL,
    [kc_cust_name1] VARCHAR (50) NULL,
    [kc_id_no1]     VARCHAR (10) NULL,
    [kc_cust_name2] VARCHAR (50) NULL,
    [kc_id_no2]     VARCHAR (10) NULL,
    CONSTRAINT [PK_kc_customerold_1__14] PRIMARY KEY CLUSTERED ([kc_case_no] ASC)
);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerold_1]
    ON [kcsd].[kc_customerold(停用)]([kc_cust_name] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerold_2]
    ON [kcsd].[kc_customerold(停用)]([kc_id_no] ASC);

