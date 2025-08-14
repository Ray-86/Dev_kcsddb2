CREATE TABLE [kcsd].[kc_courtlist] (
    [ID]            INT          IDENTITY (1, 1) NOT NULL,
    [kc_court_id]   VARCHAR (3)  NULL,
    [kc_court_desc] VARCHAR (30) NULL,
    [kc_court_area] VARCHAR (30) NULL,
    [kc_court_type] VARCHAR (30) NULL,
    CONSTRAINT [PK_kc_courtlist] PRIMARY KEY CLUSTERED ([ID] ASC)
);

