CREATE TABLE [kcsd].[kc_dudupointtasktarget_detail] (
    [ID]               INT          IDENTITY (1, 1) NOT NULL,
    [kc_target_ID]     INT          NOT NULL,
    [kc_field_name]    VARCHAR (50) NULL,
    [kc_operator_type] VARCHAR (10) NULL,
    [Value]            VARCHAR (50) NULL,
    [CreatePerson]     VARCHAR (10) NULL,
    [CreateDate]       DATETIME     NULL,
    [kc_updt_user]     VARCHAR (10) NULL,
    [kc_updt_date]     DATETIME     NULL,
    CONSTRAINT [PK_kc_dudupointtasktarget_detail] PRIMARY KEY CLUSTERED ([ID] ASC)
);

