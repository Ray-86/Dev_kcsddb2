CREATE TABLE [kcsd].[kc_saleslist] (
    [kc_case_no]    VARCHAR (10)   NOT NULL,
    [kc_town_code]  VARCHAR (3)    NULL,
    [kc_item_no]    VARCHAR (7)    NULL,
    [kc_appt_type]  VARCHAR (2)    NULL,
    [kc_sales_code] VARCHAR (4)    NULL,
    [kc_remark]     NVARCHAR (100) NULL,
    CONSTRAINT [PK_kc_saleslist] PRIMARY KEY CLUSTERED ([kc_case_no] ASC)
);

