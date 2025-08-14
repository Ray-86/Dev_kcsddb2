CREATE TABLE [kcsd].[kc_creditdata] (
    [kc_cp_no]       VARCHAR (10)  NOT NULL,
    [kc_cust_type]   SMALLINT      NOT NULL,
    [kc_id_no]       VARCHAR (10)  NOT NULL,
    [kc_credit_date] DATETIME      NOT NULL,
    [kc_credit_body] VARCHAR (MAX) NOT NULL,
    [CreatePerson]   VARCHAR (20)  NULL,
    [CreateDate]     DATETIME      NULL,
    [kc_updt_user]   VARCHAR (20)  NULL,
    [kc_updt_date]   DATETIME      NULL,
    CONSTRAINT [PK_kc_creditdata_1] PRIMARY KEY CLUSTERED ([kc_cp_no] ASC, [kc_cust_type] ASC)
);

