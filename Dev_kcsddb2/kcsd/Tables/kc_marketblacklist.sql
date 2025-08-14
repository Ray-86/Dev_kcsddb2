CREATE TABLE [kcsd].[kc_marketblacklist] (
    [kc_id_no]     VARCHAR (10)  NOT NULL,
    [IsEnable]     BIT           NULL,
    [kc_updt_date] SMALLDATETIME NULL,
    [kc_updt_user] VARCHAR (10)  NULL,
    CONSTRAINT [PK_kc_marketblacklist] PRIMARY KEY CLUSTERED ([kc_id_no] ASC)
);

