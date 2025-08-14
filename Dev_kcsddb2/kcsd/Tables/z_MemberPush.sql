CREATE TABLE [kcsd].[z_MemberPush] (
    [id]             INT           IDENTITY (1, 1) NOT NULL,
    [member_no]      NVARCHAR (11) NULL,
    [push_member_no] NVARCHAR (11) NULL,
    [create_time]    DATETIME      NULL,
    [expire_time]    DATETIME      NULL,
    [point]          INT           NULL,
    [project_name]   NVARCHAR (50) NULL,
    [can_used]       NVARCHAR (1)  NULL,
    CONSTRAINT [PK_z_MemberPush] PRIMARY KEY CLUSTERED ([id] ASC)
);

