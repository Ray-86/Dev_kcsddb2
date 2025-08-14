CREATE TABLE [kcsd].[kc_dudupointusded] (
    [ID]                   INT           IDENTITY (1, 1) NOT NULL,
    [kc_usded_no]          INT           NULL,
    [kc_member_no]         VARCHAR (11)  NULL,
    [kc_dudupoint_fee]     INT           NULL,
    [kc_usded_memo]        VARCHAR (100) NULL,
    [kc_usded_type]        VARCHAR (1)   NULL,
    [kc_customernote_memo] VARCHAR (100) NULL,
    [CreatePerson]         VARCHAR (10)  NULL,
    [CreateDate]           DATETIME      NULL,
    [kc_updt_user]         VARCHAR (10)  NULL,
    [kc_updt_date]         DATETIME      NULL,
    CONSTRAINT [PK_kc_dudupointusded] PRIMARY KEY CLUSTERED ([ID] ASC)
);

