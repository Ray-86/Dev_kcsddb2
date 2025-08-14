CREATE TABLE [kcsd].[kc_pusherarea] (
    [kc_emp_code]     VARCHAR (6) NOT NULL,
    [kc_area_code]    VARCHAR (2) NOT NULL,
    [kc_pusher_code]  VARCHAR (6) NOT NULL,
    [kc_pusher_code2] VARCHAR (6) NOT NULL,
    PRIMARY KEY CLUSTERED ([kc_emp_code] ASC, [kc_area_code] ASC)
);

