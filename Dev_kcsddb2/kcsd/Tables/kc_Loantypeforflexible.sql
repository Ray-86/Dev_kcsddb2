CREATE TABLE [kcsd].[kc_Loantypeforflexible] (
    [kc_loan_type]   VARCHAR (3)  NOT NULL,
    [kc_item_no]     INT          NOT NULL,
    [kc_loan_perd]   INT          NOT NULL,
    [kc_loan_rate]   VARCHAR (10) NOT NULL,
    [kc_lower_limit] INT          NOT NULL,
    [kc_upper_limit] INT          NOT NULL,
    [kc_add_fee]     INT          CONSTRAINT [DF_kc_Loantypeforflexible_kc_add_fee] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_kc_Loantypeforflexible] PRIMARY KEY CLUSTERED ([kc_loan_type] ASC, [kc_item_no] ASC)
);

