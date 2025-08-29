CREATE TABLE [kcsd].[kc_CpReportlistVer] (
    [ID]           INT          IDENTITY (1, 1) NOT NULL,
    [kc_list_no]   VARCHAR (20) NULL,
    [kc_list_name] VARCHAR (40) NULL,
    [kc_list_stat] VARCHAR (1)  NULL,
    [CreatePerson] VARCHAR (10) NULL,
    [CreateDate]   DATETIME     NULL,
    [kc_updt_user] VARCHAR (10) NULL,
    [kc_updt_date] DATETIME     NULL,
    CONSTRAINT [PK_kc_CpReportlistVer] PRIMARY KEY CLUSTERED ([ID] ASC)
);

