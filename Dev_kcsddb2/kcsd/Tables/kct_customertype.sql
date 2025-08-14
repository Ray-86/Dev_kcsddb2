CREATE TABLE [kcsd].[kct_customertype] (
    [kc_cust_type] VARCHAR (10) NOT NULL,
    [kc_cust_desc] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_kct_customertype] PRIMARY KEY CLUSTERED ([kc_cust_type] ASC)
);

