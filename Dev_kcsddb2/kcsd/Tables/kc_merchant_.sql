CREATE TABLE [kcsd].[kc_merchant_] (
    [kc_merchant_id] VARCHAR (4)   NOT NULL,
    [kc_hash_key]    VARCHAR (32)  NOT NULL,
    [kc_hash_iv]     VARCHAR (16)  NOT NULL,
    [kc_return_url]  VARCHAR (200) NOT NULL,
    [kc_notify_url]  VARCHAR (200) NOT NULL,
    [CreatePerson]   VARCHAR (10)  NOT NULL,
    [CreateDate]     DATETIME      NOT NULL,
    [kc_updt_user]   VARCHAR (10)  NOT NULL,
    [kc_updt_date]   SMALLDATETIME NOT NULL,
    CONSTRAINT [PK_kc_merchant] PRIMARY KEY CLUSTERED ([kc_merchant_id] ASC)
);

