CREATE TABLE [kcsd].[kc_cpreportlist] (
    [kc_item_no]     INT          IDENTITY (1, 1) NOT NULL,
    [kc_prod_type]   VARCHAR (2)  NOT NULL,
    [kc_source_type] VARCHAR (2)  NOT NULL,
    [kc_issu_code]   VARCHAR (2)  NOT NULL,
    [kc_data_type]   VARCHAR (2)  NOT NULL,
    [kc_folder_name] VARCHAR (20) NOT NULL,
    CONSTRAINT [PK_kc_cpreportlist] PRIMARY KEY CLUSTERED ([kc_item_no] ASC)
);

