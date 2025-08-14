CREATE TABLE [kcsd].[kc_reportlog] (
    [kc_item_no]   INT           IDENTITY (1, 1) NOT NULL,
    [kc_report_no] VARCHAR (20)  NULL,
    [kc_query]     VARCHAR (200) NULL,
    [kc_ip_addr]   VARCHAR (20)  NULL,
    [CreatePerson] VARCHAR (20)  NULL,
    [CreateDate]   DATETIME      NULL,
    [kc_memo]      VARCHAR (20)  NULL,
    CONSTRAINT [PK_kc_reportlog] PRIMARY KEY CLUSTERED ([kc_item_no] ASC)
);

