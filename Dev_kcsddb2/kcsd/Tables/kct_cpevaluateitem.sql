CREATE TABLE [kcsd].[kct_cpevaluateitem] (
    [kc_eval_type] VARCHAR (10)  NOT NULL,
    [kc_item_code] VARCHAR (10)  NOT NULL,
    [kc_item_desc] VARCHAR (200) NOT NULL,
    CONSTRAINT [PK_kct_cpevaluateitem] PRIMARY KEY CLUSTERED ([kc_eval_type] ASC, [kc_item_code] ASC)
);

