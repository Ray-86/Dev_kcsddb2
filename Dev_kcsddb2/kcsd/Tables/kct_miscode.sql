CREATE TABLE [kcsd].[kct_miscode] (
    [kc_kind_code] VARCHAR (2)   NOT NULL,
    [kc_mis_code]  VARCHAR (10)  NOT NULL,
    [kc_mis_desc]  VARCHAR (150) NOT NULL,
    [kc_mis_stat]  BIT           CONSTRAINT [DF_kct_miscode_kc_mis_stat] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [pk_miscode] PRIMARY KEY CLUSTERED ([kc_kind_code] ASC, [kc_mis_code] ASC),
    CONSTRAINT [ckc_status_miscode] CHECK ([kc_mis_stat]=(0) OR [kc_mis_stat]=(1))
);

