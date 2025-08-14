CREATE TABLE [kcsd].[z_Dealer] (
    [dealer_id]      INT            IDENTITY (1, 1) NOT NULL,
    [member_id]      INT            NULL,
    [store_no]       NVARCHAR (10)  NULL,
    [dealer_status]  NVARCHAR (1)   NULL,
    [dealer_name]    NVARCHAR (50)  NULL,
    [dealer_address] NVARCHAR (250) NULL,
    [dealer_desc]    NVARCHAR (250) NULL,
    CONSTRAINT [PK_z_Dealer] PRIMARY KEY CLUSTERED ([dealer_id] ASC)
);

