CREATE TABLE [kcsd].[Employee] (
    [EmpCode]     VARCHAR (6)    NOT NULL,
    [EmpName]     NVARCHAR (10)  NULL,
    [UserCode]    VARCHAR (20)   NULL,
    [AreaCode]    VARCHAR (2)    NULL,
    [EmpIdNo]     VARCHAR (20)   NULL,
    [EmpPermAddr] NVARCHAR (100) NULL,
    [JobType]     VARCHAR (1)    NULL,
    [ArrivalDate] SMALLDATETIME  NULL,
    [LeaveDate]   SMALLDATETIME  NULL,
    CONSTRAINT [PK_Employee] PRIMARY KEY CLUSTERED ([EmpCode] ASC)
);

