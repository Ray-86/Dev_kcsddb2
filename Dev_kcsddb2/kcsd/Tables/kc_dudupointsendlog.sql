CREATE TABLE [kcsd].[kc_dudupointsendlog] (
    [ID]             INT          IDENTITY (1, 1) NOT NULL,
    [kc_tasklist_no] VARCHAR (10) NULL,
    [kc_member_no]   VARCHAR (15) NULL,
    [kc_cp_no]       VARCHAR (10) NULL,
    [kc_case_no]     VARCHAR (10) NULL,
    [CreatePerson]   VARCHAR (10) NULL,
    [CreateDate]     DATETIME     NULL,
    [kc_updt_user]   VARCHAR (10) NULL,
    [kc_updt_date]   DATETIME     NULL,
    CONSTRAINT [PK_kc_dudupointsendlog] PRIMARY KEY CLUSTERED ([ID] ASC)
);

