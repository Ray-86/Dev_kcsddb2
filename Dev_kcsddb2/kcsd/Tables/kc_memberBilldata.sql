CREATE TABLE [kcsd].[kc_memberBilldata] (
    [ID]             INT          IDENTITY (1, 1) NOT NULL,
    [kc_bank_code]   VARCHAR (10) NULL,
    [kc_comp_code]   VARCHAR (2)  NULL,
    [kc_bill_code]   VARCHAR (10) NULL,
    [kc_bank_no]     VARCHAR (10) NULL,
    [kc_bankcomp_no] VARCHAR (10) NULL,
    [kc_ATM_type]    VARCHAR (20) NULL,
    [kc_ATM_strt]    INT          NULL,
    [kc_ATM_stop]    INT          NULL,
    [kc_ATM_no]      INT          NULL,
    [IsEnable]       VARCHAR (1)  NULL,
    CONSTRAINT [PK_kc_memberBilldata] PRIMARY KEY CLUSTERED ([ID] ASC)
);

