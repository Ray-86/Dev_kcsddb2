CREATE TABLE [kcsd].[kc_remittancepaylog] (
    [kc_case_no]   VARCHAR (10) NOT NULL,
    [kc_remit_amt] INT          NULL,
    [CreatePerson] VARCHAR (20) NULL,
    [CreateDate]   DATETIME     NULL,
    CONSTRAINT [PK_kc_remittancepaylog] PRIMARY KEY CLUSTERED ([kc_case_no] ASC)
);

