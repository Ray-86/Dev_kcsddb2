CREATE TABLE [kcsd].[z_BillLog] (
    [id]          INT            IDENTITY (1, 1) NOT NULL,
    [member_no]   NVARCHAR (11)  NULL,
    [expt_date]   NVARCHAR (10)  NULL,
    [pay_fee]     INT            NULL,
    [break_fee]   INT            NULL,
    [interest]    INT            NULL,
    [add_time]    DATETIME       NULL,
    [finish_time] DATETIME       NULL,
    [error]       NVARCHAR (500) NULL,
    [url]         NVARCHAR (500) NULL,
    [date]        NVARCHAR (10)  NULL,
    [duduPoint]   INT            NULL,
    CONSTRAINT [PK_z_BillLog] PRIMARY KEY CLUSTERED ([id] ASC)
);

