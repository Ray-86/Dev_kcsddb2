CREATE TABLE [kcsd].[z_Users] (
    [user_id]      INT            IDENTITY (1, 1) NOT NULL,
    [name]         NVARCHAR (50)  NULL,
    [sex]          NVARCHAR (4)   NULL,
    [mobile]       NVARCHAR (20)  NULL,
    [company_name] NVARCHAR (50)  NULL,
    [message]      NVARCHAR (500) NULL,
    [mail]         NVARCHAR (150) NULL,
    [contact_time] NVARCHAR (50)  NULL,
    [service_item] NVARCHAR (50)  NULL,
    CONSTRAINT [PK_z_Users] PRIMARY KEY CLUSTERED ([user_id] ASC)
);

