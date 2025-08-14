CREATE TABLE [kcsd].[kc_billuploadATM] (
    [kc_bill_code]     VARCHAR (10)  NOT NULL,
    [kc_date_split]    INT           NULL,
    [kc_date_len]      INT           NULL,
    [kc_date_type]     VARCHAR (1)   NULL,
    [kc_summary_split] INT           NULL,
    [kc_output_split]  INT           NULL,
    [kc_input_split]   INT           NULL,
    [kc_bill_memo]     VARCHAR (10)  NULL,
    [kc_summary_skip]  VARCHAR (300) NULL,
    CONSTRAINT [PK_kc_billuploadATM] PRIMARY KEY CLUSTERED ([kc_bill_code] ASC)
);

