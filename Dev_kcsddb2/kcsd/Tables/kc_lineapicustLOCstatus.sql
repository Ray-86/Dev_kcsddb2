CREATE TABLE [kcsd].[kc_lineapicustLOCstatus] (
    [ID]            INT           NOT NULL,
    [kc_line_id]    VARCHAR (33)  NULL,
    [kc_step_id]    VARCHAR (4)   NULL,
    [kc_step_state] INT           NULL,
    [kc_step_end]   BIT           NULL,
    [CreatePerson]  VARCHAR (20)  NULL,
    [CreateDate]    DATETIME      NULL,
    [kc_updt_user]  VARCHAR (20)  NULL,
    [kc_updt_date]  DATETIME      NULL,
    [kc_car_model]  VARCHAR (30)  NULL,
    [kc_loan_perd]  TINYINT       NULL,
    [kc_perd_fee]   INT           NULL,
    [kc_mobil_no]   VARCHAR (12)  NULL,
    [kc_cp_memo]    VARCHAR (150) NULL
);

