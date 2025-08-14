CREATE TABLE [kcsd].[kc_tmpnopv] (
    [kc_case_no]   VARCHAR (10)  NOT NULL,
    [kc_perd_no]   SMALLINT      NULL,
    [kc_expt_date] SMALLDATETIME NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [i_kc_tmpnopv]
    ON [kcsd].[kc_tmpnopv]([kc_case_no] ASC, [kc_perd_no] ASC);

