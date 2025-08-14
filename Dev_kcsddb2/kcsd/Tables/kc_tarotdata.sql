CREATE TABLE [kcsd].[kc_tarotdata] (
    [ID]                 INT           IDENTITY (1, 1) NOT NULL,
    [kc_tarot_item]      VARCHAR (10)  NULL,
    [kc_tarot_no]        VARCHAR (10)  NULL,
    [kc_tarot_type]      VARCHAR (10)  NULL,
    [kc_tarot_desc]      VARCHAR (10)  NULL,
    [kc_tarot_number]    VARCHAR (10)  NULL,
    [kc_tarot_nat]       VARCHAR (10)  NULL,
    [kc_tarot_planet]    VARCHAR (10)  NULL,
    [kc_tarot_astrology] VARCHAR (10)  NULL,
    [kc_tarot_size]      VARCHAR (10)  NULL,
    [kc_tarot_keyword]   VARCHAR (100) NULL,
    [kc_tarot_keyword1]  VARCHAR (400) NULL,
    [kc_tarot_keyword2]  VARCHAR (100) NULL,
    [kc_tarot_url]       VARCHAR (100) NULL,
    [kc_tarot_memo]      VARCHAR (100) NULL,
    CONSTRAINT [PK_kc_tarotdata] PRIMARY KEY CLUSTERED ([ID] ASC)
);

