CREATE TABLE [kcsd].[kc_twcadata] (
    [kc_twca_no]     VARCHAR (10)  NOT NULL,
    [kc_cp_no]       VARCHAR (10)  NOT NULL,
    [kc_cust_type]   SMALLINT      NOT NULL,
    [kc_id_no]       VARCHAR (10)  NULL,
    [kc_mobil_no]    VARCHAR (10)  NULL,
    [kc_twca_date]   DATETIME      NULL,
    [kc_twca_body]   VARCHAR (MAX) NULL,
    [kc_return_code] VARCHAR (10)  NULL,
    [kc_return_desc] VARCHAR (500) NULL,
    [CreatePerson]   VARCHAR (20)  NULL,
    [CreateDate]     DATETIME      NULL,
    [kc_updt_user]   VARCHAR (20)  NULL,
    [kc_updt_date]   DATETIME      NULL
);

