CREATE TABLE [kcsd].[kc_othercase] (
    [kc_cust_name] VARCHAR (10)  NOT NULL,
    [kc_id_no]     VARCHAR (10)  NOT NULL,
    [kc_comp_code] VARCHAR (30)  NOT NULL,
    [kc_buy_date]  SMALLDATETIME NOT NULL,
    [kc_memo]      TEXT          NULL,
    [kc_updt_user] VARCHAR (10)  NULL,
    [kc_updt_date] SMALLDATETIME NULL
);


GO
CREATE NONCLUSTERED INDEX [i_kc_othercase]
    ON [kcsd].[kc_othercase]([kc_id_no] ASC);

