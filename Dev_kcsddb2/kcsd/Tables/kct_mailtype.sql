CREATE TABLE [kcsd].[kct_mailtype] (
    [kc_mail_type] VARCHAR (2)  NOT NULL,
    [kc_mail_desc] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_kct_mailtype] PRIMARY KEY CLUSTERED ([kc_mail_type] ASC)
);

