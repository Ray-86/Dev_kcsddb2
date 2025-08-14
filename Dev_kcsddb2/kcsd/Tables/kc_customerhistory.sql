CREATE TABLE [kcsd].[kc_customerhistory] (
    [kc_case_no]   VARCHAR (10) NOT NULL,
    [kc_role_code] VARCHAR (5)  NOT NULL,
    [kc_area_code] VARCHAR (5)  NOT NULL,
    [kc_cust_name] VARCHAR (20) NOT NULL,
    [kc_cust_id]   VARCHAR (10) NULL,
    CONSTRAINT [PK_kc_customerhistory] PRIMARY KEY CLUSTERED ([kc_case_no] ASC, [kc_role_code] ASC)
);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerhistory_2]
    ON [kcsd].[kc_customerhistory]([kc_area_code] ASC);

