CREATE TABLE [kcsd].[AreaDefault] (
    [AreaCode]      VARCHAR (2) NOT NULL,
    [IssuCode]      VARCHAR (2) NOT NULL,
    [kc_prod_type]  VARCHAR (4) NOT NULL,
    [DefaultsBank]  VARCHAR (2) NULL,
    [kc_bill_code]  VARCHAR (3) NULL,
    [DefaultsBank2] VARCHAR (2) NULL,
    [kc_bill_code2] VARCHAR (3) NULL,
    CONSTRAINT [PK_AreaDefault] PRIMARY KEY CLUSTERED ([AreaCode] ASC, [IssuCode] ASC, [kc_prod_type] ASC)
);

