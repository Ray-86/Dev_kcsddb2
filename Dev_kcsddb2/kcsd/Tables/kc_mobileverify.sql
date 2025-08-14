CREATE TABLE [kcsd].[kc_mobileverify] (
    [kc_cp_no]       VARCHAR (10)  NOT NULL,
    [kc_verify_no]   VARCHAR (50)  NOT NULL,
    [kc_token_no]    VARCHAR (40)  NOT NULL,
    [kc_id_no]       VARCHAR (10)  NOT NULL,
    [kc_mobil_no]    VARCHAR (10)  NOT NULL,
    [kc_operator_no] VARCHAR (10)  NOT NULL,
    [kc_verify_date] DATETIME      NULL,
    [kc_finish_date] DATETIME      NULL,
    [kc_return_code] VARCHAR (10)  NULL,
    [kc_return_desc] VARCHAR (500) NULL,
    [CreatePerson]   VARCHAR (10)  NOT NULL,
    [CreateDate]     DATETIME      NOT NULL,
    [kc_updt_date]   SMALLDATETIME NOT NULL,
    [kc_updt_user]   VARCHAR (10)  NOT NULL,
    CONSTRAINT [PK_kc_mobileverify] PRIMARY KEY CLUSTERED ([kc_cp_no] ASC, [kc_verify_no] ASC)
);

