CREATE TABLE [kcsd].[kc_reference] (
    [kc_ref_no]     VARCHAR (10)  NOT NULL,
    [kc_cust_name]  VARCHAR (10)  NOT NULL,
    [kc_id_no]      VARCHAR (10)  NOT NULL,
    [kc_papa_name]  VARCHAR (10)  NULL,
    [kc_mama_name]  VARCHAR (10)  NULL,
    [kc_mate_name]  VARCHAR (10)  NULL,
    [kc_cust_name1] VARCHAR (10)  NULL,
    [kc_id_no1]     VARCHAR (10)  NULL,
    [kc_papa_name1] VARCHAR (10)  NULL,
    [kc_mama_name1] VARCHAR (10)  NULL,
    [kc_mate_name1] VARCHAR (10)  NULL,
    [kc_cust_name2] VARCHAR (10)  NULL,
    [kc_id_no2]     VARCHAR (10)  NULL,
    [kc_papa_name2] VARCHAR (10)  NULL,
    [kc_mama_name2] VARCHAR (10)  NULL,
    [kc_mate_name2] VARCHAR (10)  NULL,
    [kc_ref_memo]   VARCHAR (200) NULL,
    CONSTRAINT [PK_kc_reference] PRIMARY KEY CLUSTERED ([kc_ref_no] ASC)
);


GO
CREATE NONCLUSTERED INDEX [i_kc_reference]
    ON [kcsd].[kc_reference]([kc_id_no] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_reference_1]
    ON [kcsd].[kc_reference]([kc_id_no1] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_reference_2]
    ON [kcsd].[kc_reference]([kc_id_no2] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_reference_3]
    ON [kcsd].[kc_reference]([kc_papa_name] ASC, [kc_mama_name] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_reference_4]
    ON [kcsd].[kc_reference]([kc_papa_name1] ASC, [kc_mama_name1] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_reference_5]
    ON [kcsd].[kc_reference]([kc_papa_name2] ASC, [kc_mama_name2] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_reference_6]
    ON [kcsd].[kc_reference]([kc_cust_name] ASC, [kc_mate_name] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_reference_7]
    ON [kcsd].[kc_reference]([kc_cust_name1] ASC, [kc_mate_name1] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_reference_8]
    ON [kcsd].[kc_reference]([kc_cust_name2] ASC, [kc_mate_name2] ASC);

