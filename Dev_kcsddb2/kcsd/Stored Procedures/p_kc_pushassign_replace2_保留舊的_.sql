/*
更換催收人員: 依業務員, 更改為配合的催收人員
*/
CREATE  PROCEDURE [kcsd].[p_kc_pushassign_replace2(保留舊的)]
	@pm_run_code varchar(20)=NULL
AS

DECLARE	@wk_case_no	varchar(10),
	@wk_stop_date	datetime,	/* 原催收停止日 */
	@wk_strt_date	datetime,	/* 新催收開始日 */
	@wk_pusher_code	varchar(6),	/* 原催款人 */
	@wk_pusher_code2 varchar(6),	/* 新催款人 */
	@wk_sales_code	varchar(6),	/* 業務 */
	@wk_delay_code	varchar(4)

SELECT	@wk_case_no=NULL
SELECT	@wk_stop_date =	CONVERT(varchar(2), DATEPART(mm, GETDATE())) + '/' +
			CONVERT(varchar(2), DATEPART(dd, GETDATE())) + '/' +
			CONVERT(varchar(4), DATEPART(yy, GETDATE()))
SELECT	@wk_strt_date = @wk_stop_date


CREATE TABLE #tmp_assign_replace
(kc_case_no	varchar(10) NOT NULL,
kc_sales_code	varchar(6) NOT NULL,
kc_pusher_code	varchar(6) NOT NULL,
kc_delay_code	varchar(4) NOT NULL,
)

DECLARE	cursor_case_no	CURSOR
FOR	SELECT	kc_case_no
	FROM	kcsd.kc_customerloan
	WHERE	kc_loan_stat = 'D'
	AND	kc_pusher_code IS NOT NULL
	AND	kc_pusher_code NOT LIKE 'Z%'	/* 去除外包 */
	AND	kc_pusher_code NOT IN
		(SELECT	DelegateCode
		FROM	kcsd.Delegate
		WHERE	DelegateCode like 'L%'
		And IsEnable = 1)	/* 去除法務 */
	AND	kc_area_code = '01'		/* 只有台北 */
	/*AND	kc_case_no = '9201036'*/

OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_pusher_code = NULL, @wk_pusher_code2 = NULL, @wk_sales_code = NULL,
		@wk_delay_code = NULL

	/* 基本資料 */
	SELECT	@wk_delay_code = kc_delay_code, @wk_pusher_code = kc_pusher_code,
		@wk_sales_code = kc_sales_code
	FROM	kcsd.kc_customerloan
	WHERE	kc_case_no = @wk_case_no
	
	/* 取得新催收人員 */
	SELECT	@wk_pusher_code2 = kc_pusher_code
	FROM	kcsd.kc_employee
	WHERE	kc_emp_code = @wk_sales_code

	/* 考慮業務換區 */
	IF EXISTS (SELECT	kc_emp_code
		FROM	kcsd.kc_pusherarea
		WHERE	kc_emp_code = @wk_sales_code
		AND	kc_area_code = '01')
		SELECT	@wk_pusher_code2 = kc_pusher_code
		FROM	kcsd.kc_pusherarea
		WHERE	kc_emp_code = @wk_sales_code
		AND	kc_area_code = '01'		

	IF	@wk_pusher_code <> @wk_pusher_code2
	BEGIN
		/* Do it or test only */
		IF	@pm_run_code = 'EXECUTE'
		BEGIN
			/* 結束指派 */
			UPDATE	kcsd.kc_pushassign
			SET	kc_stop_date = @wk_stop_date
			WHERE	kc_case_no = @wk_case_no
			AND	kc_stop_date IS NULL		

			/* 新增指派 */
			INSERT	kcsd.kc_pushassign
				(kc_case_no, kc_strt_date, kc_pusher_code, kc_delay_code,
				kc_updt_user, kc_updt_date)
			VALUES	(@wk_case_no, @wk_strt_date, @wk_pusher_code2, @wk_delay_code,
				USER, GETDATE())

			UPDATE	kcsd.kc_customerloan
			SET	kc_pusher_code = @wk_pusher_code2, kc_pusher_date = @wk_strt_date
			WHERE	kc_case_no = @wk_case_no
		END

		INSERT	#tmp_assign_replace
			(kc_case_no, kc_sales_code, kc_pusher_code, kc_delay_code)
		VALUES	(@wk_case_no, @wk_sales_code, @wk_pusher_code2, @wk_delay_code)
	END

	FETCH NEXT FROM cursor_case_no INTO @wk_case_no
END

DEALLOCATE	cursor_case_no

SELECT	*
FROM	#tmp_assign_replace
ORDER BY kc_sales_code, kc_case_no

DROP TABLE #tmp_assign_replace
