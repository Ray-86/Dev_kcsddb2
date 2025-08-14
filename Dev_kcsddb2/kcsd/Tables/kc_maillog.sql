CREATE TABLE [kcsd].[kc_maillog] (
    [kc_mail_target]  VARCHAR (10)  NOT NULL,
    [kc_item_no]      SMALLINT      NOT NULL,
    [kc_mail_no]      VARCHAR (50)  NULL,
    [kc_mail_date]    SMALLDATETIME NULL,
    [kc_mail_subject] VARCHAR (100) NULL,
    [kc_mail_note]    VARCHAR (500) NULL,
    [CreatePerson]    VARCHAR (20)  NULL,
    [CreateDate]      DATETIME      NULL,
    [kc_updt_user]    VARCHAR (10)  NULL,
    [kc_updt_date]    SMALLDATETIME NULL,
    CONSTRAINT [PK_kc_maillog] PRIMARY KEY CLUSTERED ([kc_mail_target] ASC, [kc_item_no] ASC)
);

