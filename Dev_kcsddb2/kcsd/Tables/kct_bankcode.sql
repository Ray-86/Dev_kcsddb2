CREATE TABLE [kcsd].[kct_bankcode] (
    [kc_bank_code] VARCHAR (5)  NOT NULL,
    [kc_bank_name] VARCHAR (30) NOT NULL,
    [kc_acc_len]   TINYINT      NULL,
    [kc_bank_no]   VARCHAR (5)  NULL,
    CONSTRAINT [PK_kct_bankcode_1__25] PRIMARY KEY CLUSTERED ([kc_bank_code] ASC)
);

