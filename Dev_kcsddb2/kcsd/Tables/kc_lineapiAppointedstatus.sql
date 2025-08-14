CREATE TABLE [kcsd].[kc_lineapiAppointedstatus] (
    [ID]             INT            IDENTITY (1, 1) NOT NULL,
    [kc_line_id]     VARCHAR (33)   NULL,
    [kc_step_id]     VARCHAR (4)    NULL,
    [kc_step_state]  INT            NULL,
    [kc_step_end]    BIT            NULL,
    [kc_agent_code]  VARCHAR (4)    NULL,
    [kc_branch_code] VARCHAR (4)    NULL,
    [kc_cust_nameu]  NVARCHAR (60)  NULL,
    [kc_id_no]       VARCHAR (10)   NULL,
    [kc_dealer_data] NVARCHAR (500) NULL,
    [kc_dealer_memo] NVARCHAR (500) NULL,
    [kc_cp_no]       VARCHAR (10)   NULL,
    [kc_cust_type]   VARCHAR (1)    NULL,
    [CreatePerson]   VARCHAR (20)   NULL,
    [CreateDate]     DATETIME       NULL,
    [kc_updt_user]   VARCHAR (20)   NULL,
    [kc_updt_date]   DATETIME       NULL,
    CONSTRAINT [PK_kc_lineapiAppointedstatus] PRIMARY KEY CLUSTERED ([ID] ASC)
);

