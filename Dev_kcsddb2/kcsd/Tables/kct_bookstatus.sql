CREATE TABLE [kcsd].[kct_bookstatus] (
    [kc_boro_stat] VARCHAR (2)  NOT NULL,
    [kc_boro_desc] VARCHAR (40) NOT NULL,
    CONSTRAINT [PK_kct_bookstatus] PRIMARY KEY CLUSTERED ([kc_boro_stat] ASC)
);

