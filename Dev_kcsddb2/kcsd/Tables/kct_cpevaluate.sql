CREATE TABLE [kcsd].[kct_cpevaluate] (
    [kc_eval_type]  VARCHAR (10)  NOT NULL,
    [kc_eval_code]  VARCHAR (10)  NOT NULL,
    [kc_eval_desc]  VARCHAR (200) NOT NULL,
    [kc_eval_point] SMALLINT      NULL,
    CONSTRAINT [PK_kct_cpevaluate_1] PRIMARY KEY CLUSTERED ([kc_eval_type] ASC, [kc_eval_code] ASC)
);

