CREATE TABLE [kcsd].[kc_loantypecalculation_detail] (
    [kc_loan_type] VARCHAR (3)  NOT NULL,
    [kc_loan_perd] INT          NOT NULL,
    [kc_parameter] VARCHAR (50) NULL,
    [IsEnable]     BIT          NULL,
    [kc_memo]      VARCHAR (50) NULL,
    CONSTRAINT [PK_kc_loantypecalculation_detail_1] PRIMARY KEY CLUSTERED ([kc_loan_type] ASC, [kc_loan_perd] ASC)
);

