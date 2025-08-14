CREATE TABLE [kcsd].[z_DuDuApi] (
    [api_id]       INT             IDENTITY (1, 1) NOT NULL,
    [member_id]    INT             NULL,
    [dealer_acc]   NVARCHAR (50)   NULL,
    [dealer_name]  NVARCHAR (50)   NULL,
    [item]         NVARCHAR (50)   NULL,
    [item_list]    NVARCHAR (1000) NULL,
    [total_cash]   INT             NULL,
    [auto_pay]     INT             NULL,
    [nonce]        NVARCHAR (16)   NULL,
    [return_url]   NVARCHAR (1000) NULL,
    [convert_data] NVARCHAR (1500) NULL,
    [convert_code] NVARCHAR (1000) NULL,
    [add_date]     DATETIME        NULL,
    [redirect_url] NVARCHAR (1000) NULL,
    CONSTRAINT [PK_z_DuDuApi] PRIMARY KEY CLUSTERED ([api_id] ASC)
);

