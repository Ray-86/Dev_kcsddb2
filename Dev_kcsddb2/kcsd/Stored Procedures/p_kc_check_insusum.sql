-- ==========================================================================================
-- 2014/03/27 檢查保費合計(三個位置是否有差異)
-- ==========================================================================================
CREATE   PROCEDURE [kcsd].[p_kc_check_insusum] @pm_strt_date datetime, @pm_stop_date datetime 
AS
SELECT kc_case_no,kc_insu_sum as 分期合計,(SELECT isnull(sum(kc_insu_fee),0) FROM kcsd.kc_insurance_list WHERE kc_case_no = kc.kc_case_no) as 分期明細,(SELECT isnull(sum(kc_insu_fee),0) FROM kcsd.kc_insurance_list_insu WHERE kc_case_no = kc.kc_case_no) as 保險明細
FROM kcsd.kc_customerloan kc
WHERE kc_buy_date BETWEEN @pm_strt_date AND @pm_stop_date
AND
(kc_insu_sum <> (SELECT sum(kc_insu_fee) FROM kcsd.kc_insurance_list WHERE kc_case_no = kc.kc_case_no) OR
 kc_insu_sum <> (SELECT sum(kc_insu_fee) FROM kcsd.kc_insurance_list_insu WHERE kc_case_no = kc.kc_case_no) OR
 (SELECT sum(kc_insu_fee) FROM kcsd.kc_insurance_list WHERE kc_case_no = kc.kc_case_no) <>(SELECT sum(kc_insu_fee) FROM kcsd.kc_insurance_list_insu WHERE kc_case_no = kc.kc_case_no)
 )
