CREATE TABLE [kcsd].[kc_menu] (
    [kc_item_group] VARCHAR (10) NOT NULL,
    [kc_item_code]  VARCHAR (10) NOT NULL,
    [kc_item_type]  VARCHAR (10) NOT NULL,
    [kc_item_item]  VARCHAR (20) NOT NULL,
    [kc_item_desc]  VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_kc_menu] PRIMARY KEY CLUSTERED ([kc_item_group] ASC, [kc_item_code] ASC)
);

