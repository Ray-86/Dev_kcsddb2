CREATE TABLE [kcsd].[kc_debtcertificate] (
    [id]           INT            IDENTITY (1, 1) NOT NULL,
    [kc_issu_code] VARCHAR (2)    NULL,
    [kc_case_no]   VARCHAR (10)   NULL,
    [subdirectory] NVARCHAR (512) NULL,
    [kc_updt_date] DATETIME       NULL
);

