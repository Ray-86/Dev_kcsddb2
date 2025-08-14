CREATE TABLE [kcsd].[kc_invoice] (
    [kc_invo_no]   VARCHAR (10)  NOT NULL,
    [kc_case_no]   VARCHAR (10)  NOT NULL,
    [kc_invo_date] SMALLDATETIME NOT NULL,
    [kc_invo_amt]  INT           NOT NULL,
    [kc_invo_flag] VARCHAR (1)   NOT NULL,
    PRIMARY KEY CLUSTERED ([kc_invo_no] ASC)
);

