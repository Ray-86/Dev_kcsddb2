CREATE TABLE [kcsd].[kc_marketpool2] (
    [kc_case_no]   VARCHAR (10) NOT NULL,
    [kc_case_stat] VARCHAR (1)  CONSTRAINT [DF_kc_marketpool2_kc_case_stat] DEFAULT ('A') NULL,
    [kc_apply_cnt] INT          NULL,
    [kc_updt_user] VARCHAR (10) NULL,
    [kc_updt_date] DATETIME     NULL,
    CONSTRAINT [PK_kc_marketpool2] PRIMARY KEY CLUSTERED ([kc_case_no] ASC)
);

