CREATE TABLE [kcsd].[kc_billuploadConv] (
    [kc_bill_code]     VARCHAR (10) NOT NULL,
    [kc_cap_code]      VARCHAR (10) NULL,
    [kc_date_start]    INT          NULL,
    [kc_date_len]      INT          NULL,
    [kc_date_type]     VARCHAR (1)  NULL,
    [kc_summary_start] INT          NULL,
    [kc_summary_len]   INT          NULL,
    [kc_output_start]  INT          NULL,
    [kc_output_len]    INT          NULL,
    [kc_input_start]   INT          NULL,
    [kc_input_len]     INT          NULL,
    [kc_bill_desc]     VARCHAR (10) NULL,
    CONSTRAINT [PK_kc_billupload] PRIMARY KEY CLUSTERED ([kc_bill_code] ASC)
);

