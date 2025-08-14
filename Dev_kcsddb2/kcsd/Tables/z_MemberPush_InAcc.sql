CREATE TABLE [kcsd].[z_MemberPush_InAcc] (
    [id]             INT           IDENTITY (1, 1) NOT NULL,
    [push_member_no] NVARCHAR (11) NULL,
    [create_time]    DATETIME      NULL,
    [point]          INT           NULL,
    CONSTRAINT [PK_z_MemberPush_InAcc] PRIMARY KEY CLUSTERED ([id] ASC)
);

