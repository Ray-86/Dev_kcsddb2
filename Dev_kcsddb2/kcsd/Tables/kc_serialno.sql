CREATE TABLE [kcsd].[kc_serialno] (
    [kc_sys_code] VARCHAR (10)  NOT NULL,
    [kc_ser_date] SMALLDATETIME NULL,
    [kc_ser_no]   INT           NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [i_kc_serialno]
    ON [kcsd].[kc_serialno]([kc_sys_code] ASC, [kc_ser_date] ASC);

