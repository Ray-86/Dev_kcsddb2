-- ==========================================================================================
-- Usage: 更換催收人員用
--    1. pusher_old 的件全給 pusher_new
-- 或 2. pusher_old 的件, 其中是 pm_sales_code的, 全給 pusher_new
-- ==========================================================================================
-- 07/28/07 KC: 改用sub_pushassign
-- ==========================================================================================

CREATE   PROCEDURE [kcsd].[p_kc_pushassign_replace]
	@pm_run_code varchar(20)=NULL,
	@pm_pusher_old varchar(6)=NULL,	/* 原催款人 */
	@pm_pusher_new varchar(6)=NULL,	/* 新催款人 */
	@pm_sales_code varchar(6)=NULL		/* 業務員 */
AS

DECLARE	@wk_case_no	varchar(10),
	@wk_stop_date	datetime,	/* 原催收停止日 */
	@wk_strt_date	datetime,	/* 新催收開始日 */
	@wk_delay_code	varchar(4),
	@wk_count	int

/* 至少要有原催款人 */
IF	@pm_pusher_old IS NULL
	RETURN

SELECT	@wk_case_no=NULL, @wk_count = 0

-- 結束日是今天, 開始日也是今天
SELECT	@wk_stop_date =	CONVERT(varchar(2), DATEPART(mm, GETDATE())) + '/' +
			CONVERT(varchar(2), DATEPART(dd, GETDATE())) + '/' +
			CONVERT(varchar(4), DATEPART(yy, GETDATE()))
SELECT	@wk_strt_date = @wk_stop_date

CREATE TABLE #tmp_assign_replace
(kc_case_no	varchar(10) NOT NULL,
kc_delay_code	varchar(4) NOT NULL,
)

IF	@pm_sales_code IS NULL
	DECLARE	cursor_case_no	CURSOR
	FOR	SELECT	kc_case_no
		FROM	kcsd.kc_customerloan
		WHERE	kc_loan_stat = 'D'
		AND	kc_pusher_code = @pm_pusher_old
ELSE
	DECLARE	cursor_case_no	CURSOR
	FOR	SELECT	kc_case_no
		FROM	kcsd.kc_customerloan
		WHERE	kc_loan_stat = 'D'
		AND	kc_pusher_code = @pm_pusher_old
		AND	kc_sales_code = @pm_sales_code

OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_delay_code = NULL

	SELECT	@wk_delay_code = kc_delay_code
	FROM	kcsd.kc_customerloan
	WHERE	kc_case_no = @wk_case_no

	/* Do it or test only */
	IF	@pm_run_code = 'EXECUTE'
	BEGIN
		/*
		-- 結束指派
		UPDATE	kcsd.kc_pushassign
		SET	kc_stop_date = @wk_stop_date
		WHERE	kc_case_no = @wk_case_no
		AND	kc_stop_date IS NULL		

		-- 新增指派
		INSERT	kcsd.kc_pushassign
			(kc_case_no, kc_strt_date, kc_pusher_code, kc_delay_code,
			kc_updt_user, kc_updt_date)
		VALUES	(@wk_case_no, @wk_strt_date, @pm_pusher_code2, @wk_delay_code,
			USER, GETDATE())

		UPDATE	kcsd.kc_customerloan
		SET	kc_pusher_code = @pm_pusher_code2, kc_pusher_date = @wk_strt_date
			-- kc_delay_code = @wk_delay_code
		WHERE	kc_case_no = @wk_case_no */

		EXECUTE	kcsd.p_kc_pushassign_sub_assign @wk_case_no, @pm_pusher_new, @wk_delay_code
	END

	SELECT	@wk_count = @wk_count + 1

	INSERT	#tmp_assign_replace
	VALUES	(@wk_case_no, @wk_delay_code)

	FETCH NEXT FROM cursor_case_no INTO @wk_case_no
END

DEALLOCATE	cursor_case_no

SELECT	*
FROM	#tmp_assign_replace
ORDER BY kc_case_no

DROP TABLE #tmp_assign_replace
