CREATE TABLE [kcsd].[kc_dudupointsendstatlog] (
    [ID]           INT          IDENTITY (1, 1) NOT NULL,
    [kc_list_no]   VARCHAR (10) NOT NULL,
    [kc_list_stat] VARCHAR (1)  NULL,
    [kc_memo]      VARCHAR (50) NULL,
    [CreatePerson] VARCHAR (10) NULL,
    [CreateDate]   DATETIME     NULL,
    [kc_updt_user] VARCHAR (10) NULL,
    [kc_updt_date] DATETIME     NULL,
    CONSTRAINT [PK_kc_dudupointsendstatlog] PRIMARY KEY CLUSTERED ([ID] ASC)
);

