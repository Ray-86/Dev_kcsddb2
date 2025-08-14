-- ==========================================================================================
-- 01/11/2012 KC: 若 結束日>起始日, 則 刪除該筆委派
-- 02/03/08   KC: 指派日改為當日凌晨, 結束日為指派日前一天凌晨
-- 07/08/06   KC: sub to easily assgin
-- ==========================================================================================
CREATE     PROCEDURE [kcsd].[p_kc_pushassign_sub_assign] 
	@pm_case_no varchar(10)=NULL, @pm_pusher_code varchar(6)=NULL, @pm_delay_code varchar(4)='MA'
AS

DECLARE	@wk_pusher_date	datetime,
	@wk_strt_date datetime

IF	@pm_case_no IS NULL
OR	@pm_pusher_code IS NULL
	RETURN

-- 取得指派日凌晨
SELECT	@wk_pusher_date = CONVERT(varchar(20), GETDATE(), 1),
	@wk_strt_date = NULL

/* 結束先前指派指派 */
SELECT	@wk_strt_date = kc_strt_date
FROM	kcsd.kc_pushassign
WHERE	kc_case_no = @pm_case_no
AND	kc_stop_date IS NULL

-- 若 結束日<起始日, 則 刪除該筆委派
IF	@wk_strt_date > DATEADD(day, -1, @wk_pusher_date)
	DELETE
	FROM	kcsd.kc_pushassign
	WHERE	kc_case_no = @pm_case_no
	AND	kc_stop_date IS NULL		
ELSE
	UPDATE	kcsd.kc_pushassign
	SET	kc_stop_date = DATEADD(day, -1, @wk_pusher_date)
	WHERE	kc_case_no = @pm_case_no
	AND	kc_stop_date IS NULL		

/* 新增指派 */
INSERT	kcsd.kc_pushassign
	(kc_case_no, kc_strt_date, kc_pusher_code, kc_delay_code,
	kc_updt_user, kc_updt_date)
VALUES	(@pm_case_no, @wk_pusher_date, RTRIM(@pm_pusher_code), @pm_delay_code,
	USER, GETDATE() )

/* 修改主檔 */
UPDATE	kcsd.kc_customerloan
SET	kc_pusher_code = RTRIM(@pm_pusher_code), kc_pusher_date = @wk_pusher_date,
	kc_delay_code = RTRIM(@pm_delay_code),
	kc_updt_user = USER, kc_updt_date = GETDATE()
WHERE	kc_case_no = @pm_case_no
