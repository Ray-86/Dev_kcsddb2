CREATE TABLE [kcsd].[z_OrderLog] (
    [id]          INT            IDENTITY (1, 1) NOT NULL,
    [store_no]    NVARCHAR (50)  NULL,
    [price]       INT            NULL,
    [period]      INT            NULL,
    [item]        NVARCHAR (50)  NULL,
    [add_time]    DATETIME       NULL,
    [finish_time] DATETIME       NULL,
    [error]       NVARCHAR (500) NULL,
    [pay]         INT            NULL,
    [url]         NVARCHAR (MAX) NULL,
    [deal_acc]    NVARCHAR (50)  NULL,
    [order_no]    NVARCHAR (50)  NULL,
    [case_no]     NVARCHAR (50)  NULL,
    [member_no]   NVARCHAR (11)  NULL,
    CONSTRAINT [PK_z_OrderLog] PRIMARY KEY CLUSTERED ([id] ASC)
);

