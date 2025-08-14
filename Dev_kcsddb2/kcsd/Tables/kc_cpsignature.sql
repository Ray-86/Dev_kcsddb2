CREATE TABLE [kcsd].[kc_cpsignature] (
    [kc_cp_no]       VARCHAR (10)  NOT NULL,
    [kc_item_no]     SMALLINT      NOT NULL,
    [kc_id_type]     SMALLINT      NOT NULL,
    [kc_id_no]       VARCHAR (10)  NOT NULL,
    [kc_sign_date]   DATETIME      NULL,
    [kc_sign_stat]   VARCHAR (1)   NOT NULL,
    [kc_mobile_stat] VARCHAR (1)   NOT NULL,
    [kc_ca_stat]     VARCHAR (1)   NOT NULL,
    [CreatePerson]   VARCHAR (10)  NOT NULL,
    [CreateDate]     DATETIME      NOT NULL,
    [kc_updt_user]   VARCHAR (10)  NOT NULL,
    [kc_updt_date]   SMALLDATETIME NOT NULL,
    [kc_verify_no]   VARCHAR (50)  NULL,
    CONSTRAINT [PK_kc_cpsignature] PRIMARY KEY CLUSTERED ([kc_cp_no] ASC, [kc_item_no] ASC, [kc_id_type] ASC, [kc_id_no] ASC)
);

