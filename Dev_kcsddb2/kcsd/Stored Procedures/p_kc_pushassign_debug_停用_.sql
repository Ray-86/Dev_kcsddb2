/* 
   01/09/06 KC: copy from p_kc_pushassign
*/
CREATE  PROCEDURE [kcsd].[p_kc_pushassign_debug(停用)] @pm_run_code varchar(10)=NULL, @pm_case_no varchar(10)=NULL
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_pusher_code	varchar(6),		/* M0 */
	@wk_pusher_code2 varchar(6),		/* M1/MX */
	@wk_pusher_now	varchar(6),		/* 目前催款人 */
	@wk_sales_code	varchar(6),		/* 業務換區用 */
	@wk_area_code	varchar(2),		/* 業務換區用 */

	@wk_pay_type	varchar(4),
	@wk_dday_date	datetime,
	@wk_max7_date	datetime,
	@wk_maxt_date	datetime,
	@wk_maxx_date	datetime,
	@wk_delay_code	varchar(4),
	@wk_row_count	int,			/* 平均分派用01 */
	@wk_row_count6	int,			/* 平均分配用06 */
	@wk_over_amt	int

CREATE TABLE #tmp_pushassign_test
(kc_case_no	varchar(10),
kc_delay_code	varchar(4),
kc_pusher_code	varchar(6),
kc_pusher_date	smalldatetime,
kc_over_amt	int
)

SELECT	@wk_case_no=NULL, @wk_pusher_code=NULL, @wk_pusher_code2=NULL,
	@wk_sales_code=NULL,
	@wk_max7_date=NULL, @wk_maxt_date=NULL, @wk_maxx_date=NULL,
	@wk_delay_code=NULL

SELECT	@wk_row_count  = DATEPART(y, GETDATE())-1		/* 簡易亂數 */
SELECT	@wk_row_count6 = DATEPART(y, GETDATE())-1		/* 簡易亂數 */

SELECT	@wk_max7_date = MAX(kc_pay_date)
FROM	kcsd.kc_loanpayment
WHERE	kc_pay_type = '7'
AND	kc_pay_date < GETDATE()

SELECT	@wk_maxt_date = MAX(kc_pay_date)
FROM	kcsd.kc_loanpayment
WHERE	kc_pay_type = 'T'
AND	kc_pay_date < GETDATE()

SELECT	@wk_max7_date = DATEADD(day, -1, @wk_max7_date),
	@wk_maxt_date = DATEADD(day, -1, @wk_maxt_date)

DECLARE	cursor_case_no	CURSOR
FOR	SELECT	kc_case_no
	FROM	kcsd.kc_customerloan
	WHERE	kc_loan_stat = 'D'
	AND	DATEDIFF(month, kc_dday_date, GETDATE()) BETWEEN 0 AND 1
	AND	kc_case_no = @pm_case_no
	/* 轉換為 P1用
	AND	(	kc_pusher_code = '1105'
		OR	kc_pusher_code = '1106'
		OR	kc_pusher_code = '1110'
		OR	kc_pusher_code = '1113'
		OR	kc_pusher_code = '1168' ) */
	/*AND	kc_pusher_code = '1132' */
	/* 轉換為 P61用
	AND	(	kc_pusher_code = '1139'
		OR	kc_pusher_code = '1142' ) */
	ORDER BY kc_over_amt DESC

OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	'Enter while LOOP'
	SELECT	@wk_pusher_code = NULL, @wk_pusher_code2 = NULL,
		@wk_pusher_now = NULL,
		@wk_dday_date = NULL, @wk_pay_type = NULL,
		@wk_sales_code = NULL, @wk_area_code = NULL,
		@wk_over_amt = 0
	SELECT	@wk_maxx_date = DATEADD(day, -5, GETDATE())

	/* Get current pusher */
	SELECT	@wk_pusher_now = kc_pusher_code
	FROM	kcsd.kc_customerloan
	WHERE	kc_case_no = @wk_case_no
		
	/* 尚未有催款人, 則自動指派 */
	/* 若指派給 P0, 則重新分派給 P1~PX */
	/* 轉換 P1, P61 時必須暫停此條件 */
	IF NOT EXISTS		
		(SELECT	'X'
		FROM	kcsd.kc_pushassign
		WHERE	kc_case_no = @wk_case_no
		AND	kc_stop_date IS NULL)
	OR	@wk_pusher_now = 'P0'
	BEGIN
		SELECT	'Enter Assign block'
		/* get basic data */
		SELECT	@wk_dday_date = kc_dday_date, @wk_pay_type = kc_pay_type,
			@wk_sales_code = kc_sales_code, @wk_area_code = kc_area_code,
			@wk_over_amt = kc_over_amt
		FROM	kcsd.kc_customerloan
		WHERE	kc_case_no = @wk_case_no

		IF	@wk_pay_type = '7'
			SELECT	@wk_maxx_date = @wk_max7_date
		IF	@wk_pay_type = 'T'
			SELECT	@wk_maxx_date = @wk_maxt_date

		SELECT	@wk_dday_date, @wk_maxx_date

		IF	@wk_dday_date < @wk_maxx_date
		BEGIN
			EXECUTE kcsd.p_kc_pushassign_calcm @wk_case_no, @wk_delay_code OUTPUT
			IF	@wk_area_code = '06'
			BEGIN
				EXECUTE kcsd.p_kc_pushassign_sub_pusher
					@wk_pusher_code OUTPUT, @wk_case_no, @wk_delay_code, @wk_row_count6

				IF	@wk_pusher_code LIKE 'P%'
					SELECT	@wk_row_count6 = @wk_row_count6 + 1
			END
			ELSE
			BEGIN
				/* 取得催款人 */
				EXECUTE kcsd.p_kc_pushassign_sub_pusher
					@wk_pusher_code OUTPUT, @wk_case_no, @wk_delay_code, @wk_row_count

				SELECT	@wk_pusher_code

				IF	@wk_area_code = '01'
				AND	@wk_pusher_code LIKE 'P%'
				AND	@wk_pusher_code <> 'P0'
					SELECT	@wk_row_count = @wk_row_count + 1
			END
		END

		IF	@wk_pusher_code IS NOT NULL
		AND	@wk_dday_date < @wk_maxx_date
		BEGIN
			INSERT	#tmp_pushassign_test
				(kc_case_no, kc_delay_code, kc_pusher_code, kc_pusher_date, kc_over_amt)
			VALUES	(@wk_case_no, @wk_delay_code, @wk_pusher_code, GETDATE(), @wk_over_amt)

			IF	@pm_run_code = 'EXECUTE'
			BEGIN
				/* 結束先前指派指派 */
				UPDATE	kcsd.kc_pushassign
				SET	kc_stop_date = GETDATE()
				WHERE	kc_case_no = @wk_case_no
				AND	kc_stop_date IS NULL		

				/* 新增指派 */
				INSERT	kcsd.kc_pushassign
					(kc_case_no, kc_strt_date, kc_pusher_code, kc_delay_code,
					kc_updt_user, kc_updt_date)
				VALUES	(@wk_case_no, GETDATE(), @wk_pusher_code, @wk_delay_code,
					USER, GETDATE() )

				/* 修改主檔 */
				UPDATE	kcsd.kc_customerloan

				SET	kc_pusher_code = @wk_pusher_code, kc_pusher_date = GETDATE(),

					kc_delay_code = @wk_delay_code,
					kc_updt_user = USER, kc_updt_date = GETDATE()
				WHERE	kc_case_no = @wk_case_no
			END
		END	
	END
	FETCH NEXT FROM cursor_case_no INTO @wk_case_no
END


DEALLOCATE	cursor_case_no

SELECT	*
FROM	#tmp_pushassign_test
ORDER BY kc_case_no

DROP TABLE #tmp_pushassign_test
