CREATE TABLE [kcsd].[kc_menuaccess] (
    [kc_item_item]  VARCHAR (50) NOT NULL,
    [kc_grant_name] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_kc_menuaccess] PRIMARY KEY CLUSTERED ([kc_item_item] ASC, [kc_grant_name] ASC)
);

