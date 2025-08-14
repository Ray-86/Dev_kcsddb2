CREATE TABLE [kcsd].[kc_checkserial] (
    [kc_acc_code] VARCHAR (10) NOT NULL,
    [kc_chk_no]   VARCHAR (20) NOT NULL,
    CONSTRAINT [PK_kc_checkserial] PRIMARY KEY CLUSTERED ([kc_acc_code] ASC)
);

