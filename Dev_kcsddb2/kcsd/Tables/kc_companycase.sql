CREATE TABLE [kcsd].[kc_companycase] (
    [kc_strt_no]    VARCHAR (10) NOT NULL,
    [kc_stop_no]    VARCHAR (10) NOT NULL,
    [kc_comp_char2] VARCHAR (2)  NOT NULL,
    [kc_acc_code]   VARCHAR (2)  NULL,
    CONSTRAINT [PK_kc_companycase_1__15] PRIMARY KEY CLUSTERED ([kc_strt_no] ASC)
);


GO
CREATE NONCLUSTERED INDEX [i_kc_compcase]
    ON [kcsd].[kc_companycase]([kc_comp_char2] ASC);

