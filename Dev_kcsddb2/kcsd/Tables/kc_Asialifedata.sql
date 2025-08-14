CREATE TABLE [kcsd].[kc_Asialifedata] (
    [ID]                             INT           IDENTITY (1, 1) NOT NULL,
    [special_station_no]             VARCHAR (10)  NULL,
    [special_collection_type_no]     VARCHAR (10)  NULL,
    [collection_station_no]          VARCHAR (10)  NULL,
    [collection_type]                VARCHAR (1)   NULL,
    [collection_amount]              VARCHAR (10)  NULL,
    [collection_no]                  VARCHAR (20)  NULL,
    [collection_at]                  VARCHAR (20)  NULL,
    [collection_order_no]            VARCHAR (20)  NULL,
    [special_collection_service_fee] VARCHAR (10)  NULL,
    [token]                          VARCHAR (200) NULL,
    [ClientIP]                       VARCHAR (10)  NULL,
    [CreateDate]                     DATETIME      NULL,
    [data_chk_flag]                  VARCHAR (1)   NULL,
    CONSTRAINT [PK_kc_Xmarketdata] PRIMARY KEY CLUSTERED ([ID] ASC)
);

