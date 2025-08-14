CREATE TABLE [kcsd].[kc_billlist] (
    [UserSeq]      VARCHAR (4) NOT NULL,
    [kc_area_code] VARCHAR (2) NOT NULL,
    [kc_list_type] VARCHAR (2) NOT NULL,
    CONSTRAINT [PK_kc_billlist] PRIMARY KEY CLUSTERED ([UserSeq] ASC, [kc_area_code] ASC, [kc_list_type] ASC)
);

