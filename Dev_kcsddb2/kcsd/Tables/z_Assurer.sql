CREATE TABLE [kcsd].[z_Assurer] (
    [assurer_id]         INT            IDENTITY (1, 1) NOT NULL,
    [cp_no]              NVARCHAR (50)  NULL,
    [name]               NVARCHAR (50)  NULL,
    [dob]                NVARCHAR (20)  NULL,
    [householdAddress]   NVARCHAR (250) NULL,
    [householdPhone]     NVARCHAR (20)  NULL,
    [residentialAddress] NVARCHAR (250) NULL,
    [residentialPhone]   NVARCHAR (20)  NULL,
    [companyName]        NVARCHAR (50)  NULL,
    [companyPhone]       NVARCHAR (20)  NULL,
    [companyAddress]     NVARCHAR (250) NULL,
    [mobilePhone]        NVARCHAR (20)  NULL,
    [add_time]           DATETIME       NULL,
    [idNumber]           NVARCHAR (10)  NULL,
    [Insured_cp_no]      NVARCHAR (50)  NULL,
    [insured_mobile]     NVARCHAR (50)  NULL,
    [insured_id_no]      NVARCHAR (10)  NULL,
    CONSTRAINT [PK_z_Assurer] PRIMARY KEY CLUSTERED ([assurer_id] ASC)
);

