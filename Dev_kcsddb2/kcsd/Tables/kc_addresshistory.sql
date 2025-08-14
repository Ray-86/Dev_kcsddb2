CREATE TABLE [kcsd].[kc_addresshistory] (
    [kc_id_no]     VARCHAR (10)  NOT NULL,
    [kc_addr_type] VARCHAR (2)   NOT NULL,
    [kc_updt_date] DATETIME      NULL,
    [kc_addr_data] VARCHAR (100) NULL,
    [kc_updt_user] VARCHAR (10)  NULL,
    [kc_addr_note] VARCHAR (50)  NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [i_kc_addresshistory]
    ON [kcsd].[kc_addresshistory]([kc_id_no] ASC, [kc_addr_type] ASC, [kc_updt_date] ASC);

