/* 3/11/06 KC: 補計算指派法務外包逾期金額及違約金, Maybe run once only */
CREATE  PROCEDURE [kcsd].[p_kc_pushassign_calcamt]
	@pm_run_code varchar(20)=NULL,
	@pm_age_date datetime=NULL,		/* 通常上個月最後一天 */
	@pm_case_no varchar(10)=NULL		/* single case */
AS
DECLARE	@wk_case_no	varchar(10),

	@wk_due_date	datetime,		/* 計算截止時間 */
	@wk_over_amt	int,			/* 逾期金額 */
	@wk_arec_amt	int,			/* 未繳金額 */
	@wk_dday_date	datetime,		/* dummy for p_kc_getoveramt */
	@wk_break_amt	int,

	/* update use */
	@wk_strt_date	datetime		/* age_date 前最後指派日 */

CREATE TABLE #tmp_calc_amt
(kc_case_no	varchar(10),
kc_over_amt	int,
kc_break_amt	int	NULL
)

SELECT	@wk_case_no=NULL

/* 參數為Null: 預設帳齡計算基準日為 上月最後一天 */
IF	@pm_age_date IS NULL
BEGIN
	SELECT	@pm_age_date = CONVERT(char(2), DATEPART(month, GETDATE())) + '/1/'
		+ CONVERT(char(4), DATEPART(year, GETDATE()))
	SELECT	@pm_age_date = DATEADD(day, -1, @pm_age_date)
END

SELECT	@wk_due_date = DATEADD(day, 1, @pm_age_date)

IF	@pm_case_no IS NULL
BEGIN	/* Gerneral */
	DECLARE	cursor_caseno_calcamt	CURSOR
	FOR	SELECT	kc_case_no
		FROM	kcsd.kc_tmpnopv2
END
ELSE	/* Specified case */
BEGIN
	DECLARE	cursor_caseno_calcamt	CURSOR
	FOR	SELECT	@pm_case_no
END

OPEN cursor_caseno_calcamt
FETCH NEXT FROM cursor_caseno_calcamt INTO @wk_case_no


WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_over_amt = 0, @wk_arec_amt = 0, @wk_dday_date = NULL, @wk_break_amt=0,
		@wk_strt_date = NULL

	/* 計算逾期金額 */
	EXECUTE	kcsd.p_kc_getoveramt @wk_case_no, @wk_due_date, @wk_over_amt OUTPUT, @wk_arec_amt OUTPUT, @wk_dday_date OUTPUT

	/* 計算天數違約金 */
	EXECUTE	kcsd.p_kc_updateloanstatus_sub1 @wk_case_no, @wk_break_amt OUTPUT, @wk_due_date

	INSERT	#tmp_calc_amt
		(kc_case_no, kc_over_amt, kc_break_amt)
	VALUES	(@wk_case_no, @wk_over_amt, @wk_break_amt)

	IF	@pm_run_code = 'EXECUTE'
	BEGIN
		SELECT	@wk_strt_date = MAX(kc_strt_date)
		FROM	kcsd.kc_pushassign
		WHERE	kc_case_no = @wk_case_no
		AND	kc_strt_date <= @pm_age_date

		IF	@wk_strt_date IS NOT NULL
		BEGIN		
			UPDATE	kcsd.kc_pushassign
			SET	kc_pusher_amt = @wk_over_amt,
				kc_break_amt = @wk_break_amt
			WHERE	kc_case_no = @wk_case_no
			AND	kc_strt_date = @wk_strt_date
		END
	END

	FETCH NEXT FROM cursor_caseno_calcamt INTO @wk_case_no
END

DEALLOCATE	cursor_caseno_calcamt

SELECT	*
FROM	#tmp_calc_amt
