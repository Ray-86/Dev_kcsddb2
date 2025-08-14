CREATE TABLE [kcsd].[kct_regioncityMap] (
    [kc_city_id]          INT           IDENTITY (1, 1) NOT NULL,
    [kc_city_name]        NVARCHAR (50) NOT NULL,
    [kc_city_mapped_name] NVARCHAR (30) NULL,
    CONSTRAINT [PK_kct_regioncityMap] PRIMARY KEY CLUSTERED ([kc_city_id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'編號 (識別碼)', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kct_regioncityMap', @level2type = N'COLUMN', @level2name = N'kc_city_id';

