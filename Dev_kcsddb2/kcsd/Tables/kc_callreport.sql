CREATE TABLE [kcsd].[kc_callreport] (
    [kc_file_url]     VARCHAR (400) NOT NULL,
    [kc_call_date]    SMALLDATETIME NULL,
    [kc_call_user]    VARCHAR (10)  NULL,
    [kc_file_seconds] INT           NULL,
    [CreatePerson]    VARCHAR (10)  NULL,
    [CreateDate]      SMALLDATETIME NULL,
    CONSTRAINT [PK_kc_callreport] PRIMARY KEY CLUSTERED ([kc_file_url] ASC)
);

