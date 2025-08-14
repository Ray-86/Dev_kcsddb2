CREATE TABLE [kcsd].[kc_invoicedetail] (
    [kc_invo_no]   VARCHAR (10) NOT NULL,
    [kc_item_no]   TINYINT      NOT NULL,
    [kc_item_name] VARCHAR (30) NOT NULL,
    [kc_item_amt]  INT          NOT NULL,
    PRIMARY KEY CLUSTERED ([kc_invo_no] ASC, [kc_item_no] ASC)
);

