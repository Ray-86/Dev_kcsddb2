CREATE TABLE [kcsd].[kc_cpapplylist] (
    [UserSeq]        VARCHAR (4) NOT NULL,
    [kc_prod_type]   VARCHAR (2) NOT NULL,
    [kc_cpappd_type] VARCHAR (2) NULL,
    CONSTRAINT [PK_kc_cpapplylist] PRIMARY KEY CLUSTERED ([UserSeq] ASC, [kc_prod_type] ASC)
);

