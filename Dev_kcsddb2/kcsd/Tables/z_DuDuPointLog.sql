CREATE TABLE [kcsd].[z_DuDuPointLog] (
    [id]          INT            IDENTITY (1, 1) NOT NULL,
    [member_no]   NVARCHAR (11)  NULL,
    [add_time]    DATETIME       NULL,
    [finish_time] DATETIME       NULL,
    [error]       NVARCHAR (500) NULL,
    [url]         NVARCHAR (500) NULL,
    [date]        NVARCHAR (10)  NULL,
    [case_no]     NVARCHAR (50)  NULL,
    [perd_no]     NVARCHAR (3)   NULL,
    CONSTRAINT [PK_z_DuDuPointLog] PRIMARY KEY CLUSTERED ([id] ASC)
);

