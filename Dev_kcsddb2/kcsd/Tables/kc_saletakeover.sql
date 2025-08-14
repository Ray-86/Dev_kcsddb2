CREATE TABLE [kcsd].[kc_saletakeover] (
    [kc_cp_no]         VARCHAR (10)  NOT NULL,
    [kc_takeover_memo] VARCHAR (300) NULL,
    [CreatePerson]     VARCHAR (10)  NULL,
    [CreateDate]       DATETIME      NULL,
    [kc_updt_date]     SMALLDATETIME NULL,
    [kc_updt_user]     VARCHAR (10)  NULL,
    CONSTRAINT [PK_kc_saletakeover] PRIMARY KEY CLUSTERED ([kc_cp_no] ASC)
);

