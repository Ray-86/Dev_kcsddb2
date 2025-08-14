CREATE TABLE [kcsd].[kc_mms] (
    [kc_case_no]     VARCHAR (10) NOT NULL,
    [kc_item_no]     INT          NOT NULL,
    [kc_msg_date]    DATETIME     NULL,
    [kc_mobil_no]    VARCHAR (10) NULL,
    [kc_mms_subject] VARCHAR (20) NULL,
    [kc_mms_content] VARCHAR (50) NULL,
    [kc_mms_memo]    VARCHAR (50) NULL,
    [kc_mms_id]      VARCHAR (10) NULL,
    [kc_mms_stat]    INT          NULL,
    CONSTRAINT [PK_kc_mms] PRIMARY KEY CLUSTERED ([kc_case_no] ASC, [kc_item_no] ASC)
);

