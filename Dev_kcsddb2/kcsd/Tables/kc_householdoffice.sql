CREATE TABLE [kcsd].[kc_householdoffice] (
    [ID]           INT          IDENTITY (1, 1) NOT NULL,
    [kc_area_desc] VARCHAR (50) NULL,
    [kc_area_addr] VARCHAR (50) NULL,
    CONSTRAINT [PK_kc_householdoffice] PRIMARY KEY CLUSTERED ([ID] ASC)
);

