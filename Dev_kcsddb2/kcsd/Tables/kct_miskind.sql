CREATE TABLE [kcsd].[kct_miskind] (
    [kc_kind_code] VARCHAR (2)  NOT NULL,
    [kc_kind_desc] VARCHAR (30) NOT NULL,
    [kc_kind_len]  SMALLINT     NOT NULL,
    CONSTRAINT [pk_miskind] PRIMARY KEY CLUSTERED ([kc_kind_code] ASC),
    CONSTRAINT [ckc_len_miskind] CHECK ([kc_kind_len]>=(1) AND [kc_kind_len]<=(10))
);

