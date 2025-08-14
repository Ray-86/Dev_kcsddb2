CREATE    PROCEDURE [kcsd].[p_kc_pushassign_monthly_specify(保留舊的)]
@pm_run_code varchar(20)=NULL, @pm_m1_date datetime=NULL
AS

DECLARE	@wk_case_no	varchar(10),
	@wk_pusher_code	varchar(6),	/* 原催款人 */
	@wk_pusher_code2 varchar(6),	/* 預設M1催款人 */
	@wk_sales_code	varchar(6),
	@wk_area_code	varchar(2),
	
	@wk_m0stop_date	datetime,	/* M0 結束日 */
	@wk_m1strt_date	datetime,	/* M1 起始日 */
	@wk_delay_code	varchar(4),
	@wk_count	int

SELECT	@wk_case_no=NULL, @wk_pusher_code=NULL, @wk_sales_code=NULL,
	@wk_count = 0

/* run log */
IF	@pm_run_code = 'EXECUTE'
	EXECUTE kcsd.p_kc_runlog 'M1'

CREATE TABLE #tmp_assign
(kc_case_no	varchar(10) NOT NULL,
kc_pusher_code	varchar(6) NOT NULL,
kc_pusher_code2	varchar(6) NOT NULL,
kc_delay_code	varchar(2) NULL)

/* 參數為Null: 預設M1基準日為上個月1日 */
IF	@pm_m1_date IS NULL
BEGIN
	SELECT	@pm_m1_date = CONVERT(char(2), DATEPART(month, GETDATE())) + '/1/'
		+ CONVERT(char(4), DATEPART(year, GETDATE()))
	SELECT	@pm_m1_date = DATEADD(month, -1, @pm_m1_date)
END

/* M1 開始日為 M1基準日+1個月, M0結束日為M1開始日-1分鐘 */
SELECT	@wk_m1strt_date = DATEADD(month, 1, @pm_m1_date),
	@wk_delay_code = 'M1'
SELECT	@wk_m0stop_date = DATEADD(day, -1, @wk_m1strt_date)


/*  派件需符合4條件:
條件1: 逾期
條件2: 逾期日在m1基準日前
條件3: 非人工派件者(hour=0)
條件4: 已M1/MA派件者, 不重新派件
*/
DECLARE	cursor_case_no	CURSOR
FOR	SELECT	c.kc_case_no
	FROM	kcsd.kc_customerloan c, kcsd.kc_tmpnopv2 t
	WHERE	kc_loan_stat = 'D'
	AND	kc_dday_date < @pm_m1_date
	/* AND	NOT ( DATEPART(hour, kc_pusher_date)=0 AND DATEPART(minute, kc_pusher_date)=0 ) */
	AND	c.kc_case_no NOT IN
		(SELECT	kc_case_no
		FROM	kcsd.kc_pushassign
		WHERE	kc_stop_date IS NULL
		AND	(kc_delay_code ='M1' 
			OR kc_delay_code= 'MA')
		)
	AND	c.kc_case_no = t.kc_case_no

OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_pusher_code=NULL, @wk_pusher_code2=NULL, @wk_sales_code=NULL,
		@wk_area_code = NULL

	/* 基本資料 */
	SELECT	@wk_sales_code = kc_sales_code, @wk_area_code = kc_area_code
	FROM	kcsd.kc_customerloan
	WHERE	kc_case_no = @wk_case_no

	IF	EXISTS	(SELECT	kc_emp_code
			FROM	kcsd.kc_pusherarea
			WHERE	kc_emp_code = @wk_sales_code
			AND	kc_area_code = @wk_area_code)
	BEGIN	/* 業務換區 */
		SELECT	@wk_pusher_code2 = kc_pusher_code2
		FROM	kcsd.kc_pusherarea
		WHERE	kc_emp_code = @wk_sales_code
		AND	kc_area_code = @wk_area_code
	END
	ELSE		
	BEGIN	/* 業務無換區, 找M1催收人  */
		SELECT	@wk_pusher_code2 = e.kc_pusher_code2
		FROM	kcsd.kc_customerloan c, kcsd.kc_employee e
		WHERE	c.kc_case_no = @wk_case_no
		AND	c.kc_sales_code = e.kc_emp_code
	END

	/* get current pusher */
	SELECT	@wk_pusher_code = kc_pusher_code
	FROM	kcsd.kc_pushassign
	WHERE	kc_case_no = @wk_case_no
	AND	kc_stop_date IS NULL

	IF	@wk_pusher_code2 IS NOT NULL
	BEGIN
		/* Do it or test only */
		IF	@pm_run_code = 'EXECUTE'
		BEGIN
			/* 結束M0指派 */
			UPDATE	kcsd.kc_pushassign
			/*SET	kc_stop_date = GETDATE()*/
			SET	kc_stop_date = @wk_m0stop_date
			WHERE	kc_case_no = @wk_case_no
			AND	kc_stop_date IS NULL		

			/* 新增M1指派 */
			INSERT	kcsd.kc_pushassign
				(kc_case_no, kc_strt_date, kc_pusher_code, kc_delay_code,
				kc_updt_user, kc_updt_date)
			VALUES	(@wk_case_no, @wk_m1strt_date, @wk_pusher_code2, @wk_delay_code,
				USER, GETDATE())

			UPDATE	kcsd.kc_customerloan
			SET	kc_pusher_code = @wk_pusher_code2, kc_pusher_date = @wk_m1strt_date,
				kc_delay_code = @wk_delay_code
			WHERE	kc_case_no = @wk_case_no
		END

		SELECT	@wk_count = @wk_count + 1

		IF	@wk_pusher_code IS NULL
			SELECT	@wk_pusher_code = @wk_pusher_code2
		INSERT	#tmp_assign
		VALUES	(@wk_case_no, @wk_pusher_code, @wk_pusher_code2, @wk_delay_code)
	END
	FETCH NEXT FROM cursor_case_no INTO @wk_case_no
END

DEALLOCATE	cursor_case_no

SELECT	t.*, e.DelegateName
FROM	#tmp_assign t, kcsd.Delegate e
WHERE	t.kc_pusher_code2 = e.DelegateCode
ORDER BY t.kc_case_no

DROP TABLE #tmp_assign

SELECT	@wk_count, @pm_m1_date, @wk_m0stop_date, @wk_m1strt_date


/* 已繳清或正常的案件, 結束催收 */
/*IF	@pm_run_code = 'EXECUTE'
	EXECUTE kcsd.p_kc_pushassign_close 'M1', 'EXECUTE'
*/
