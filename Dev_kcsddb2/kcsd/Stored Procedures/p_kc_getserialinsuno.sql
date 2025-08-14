
---- ==========================================================================================
-- 2017-06-05 保險待補取號
-- ==========================================================================================
CREATE    PROCEDURE [kcsd].[p_kc_getserialinsuno]
AS

SELECT Top 1 kc_insu_no FROM 
(SELECT '待補'+CONVERT(VARCHAR(4),FORMAT(N,'000')) AS kc_insu_no FROM kcsd.Tally WHERE N < 1000 AND N > 100) AS A 
WHERE A.kc_insu_no NOT IN (SELECT kc_insu_no FROM kcsd.kc_insurance where kc_insu_no like '待補%')

