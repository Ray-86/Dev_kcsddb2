CREATE TABLE [kcsd].[kc_LinePushList_detail] (
    [ID]           INT          IDENTITY (1, 1) NOT NULL,
    [kc_list_no]   VARCHAR (10) NULL,
    [kc_id_no]     VARCHAR (10) NULL,
    [kc_line_id]   VARCHAR (33) NULL,
    [CreatePerson] VARCHAR (10) NULL,
    [CreateDate]   DATETIME     NULL,
    [kc_updt_user] VARCHAR (10) NULL,
    [kc_updt_date] DATETIME     NULL,
    [kc_finish]    BIT          NULL,
    CONSTRAINT [PK_kc_LinePushList_detail] PRIMARY KEY CLUSTERED ([ID] ASC)
);

