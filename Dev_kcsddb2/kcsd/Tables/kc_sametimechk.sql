CREATE TABLE [kcsd].[kc_sametimechk] (
    [kc_name]     VARCHAR (20) NOT NULL,
    [kc_button]   VARCHAR (10) NOT NULL,
    [kc_exe_stat] VARCHAR (1)  NULL,
    CONSTRAINT [PK_kc_sametimechk] PRIMARY KEY CLUSTERED ([kc_name] ASC, [kc_button] ASC)
);

