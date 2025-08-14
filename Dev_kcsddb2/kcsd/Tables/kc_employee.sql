CREATE TABLE [kcsd].[kc_employee] (
    [kc_emp_code]      VARCHAR (6)   NOT NULL,
    [kc_emp_name]      NVARCHAR (10) NULL,
    [kc_user_name]     VARCHAR (20)  NULL,
    [kc_job_type]      VARCHAR (1)   NULL,
    [kc_pusher_code]   VARCHAR (6)   NULL,
    [kc_pusher_code2]  VARCHAR (6)   NULL,
    [kc_area_code]     VARCHAR (2)   NULL,
    [kc_leave_date]    SMALLDATETIME NULL,
    [kc_contact_name]  VARCHAR (10)  NULL,
    [kc_contact_data]  VARCHAR (30)  NULL,
    [kc_contact_data2] VARCHAR (30)  NULL,
    [kc_contact_data3] VARCHAR (30)  NULL,
    [kc_phone_ext]     VARCHAR (10)  NULL,
    CONSTRAINT [PK_kc_employee_1__10] PRIMARY KEY CLUSTERED ([kc_emp_code] ASC)
);

