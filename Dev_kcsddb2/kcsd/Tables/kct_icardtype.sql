CREATE TABLE [kcsd].[kct_icardtype] (
    [kc_icard_type] VARCHAR (2)  NOT NULL,
    [kc_type_desc]  VARCHAR (20) NOT NULL,
    [kc_digi_len]   TINYINT      NOT NULL,
    CONSTRAINT [PK___1__13] PRIMARY KEY CLUSTERED ([kc_icard_type] ASC)
);

