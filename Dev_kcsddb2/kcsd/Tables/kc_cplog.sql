CREATE TABLE [kcsd].[kc_cplog] (
    [kc_cp_no]     VARCHAR (10) NOT NULL,
    [kc_item_no]   VARCHAR (3)  NOT NULL,
    [kc_type]      VARCHAR (20) NULL,
    [kc_ip_addr]   VARCHAR (20) NULL,
    [CreatePerson] VARCHAR (10) NULL,
    [CreateDate]   DATETIME     NULL,
    [kc_updt_user] VARCHAR (10) NULL,
    [kc_updt_date] DATETIME     NULL,
    [kc_memo]      VARCHAR (50) NULL,
    CONSTRAINT [PK_kc_cplog] PRIMARY KEY CLUSTERED ([kc_cp_no] ASC, [kc_item_no] ASC)
);

