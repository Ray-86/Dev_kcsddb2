CREATE TABLE [kcsd].[kc_noticecfm] (
    [kc_cp_no]       VARCHAR (10) NOT NULL,
    [kc_item_no]     INT          NOT NULL,
    [kc_notice_user] VARCHAR (10) NULL,
    [kc_notice_date] DATETIME     NULL,
    [kc_notice_flag] VARCHAR (1)  NULL,
    [kc_updt_user]   VARCHAR (10) NULL,
    [kc_updt_date]   DATETIME     NULL,
    [kc_accept_user] VARCHAR (10) NULL,
    [kc_accept_date] DATETIME     NULL,
    [kc_notice_type] VARCHAR (1)  NULL
);

