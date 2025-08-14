CREATE TABLE [kcsd].[kct_mailreject] (
    [kc_rej_code] VARCHAR (2)  NOT NULL,
    [kc_rej_desc] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_kct_mailreject] PRIMARY KEY CLUSTERED ([kc_rej_code] ASC)
);

