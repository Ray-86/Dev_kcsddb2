CREATE TABLE [kcsd].[CacheKey] (
    [tableName]    VARCHAR (50) NOT NULL,
    [currentKey]   VARCHAR (30) NOT NULL,
    [kc_updt_date] DATETIME     NULL,
    CONSTRAINT [PK_CacheKey] PRIMARY KEY CLUSTERED ([tableName] ASC)
);

