CREATE TABLE [kcsd].[kct_insureward] (
    [kc_rewd_type]  VARCHAR (2)  NOT NULL,
    [kc_rewd_desc]  VARCHAR (20) NOT NULL,
    [kc_insu_month] SMALLINT     NULL,
    CONSTRAINT [PK___2__19] PRIMARY KEY CLUSTERED ([kc_rewd_type] ASC)
);

