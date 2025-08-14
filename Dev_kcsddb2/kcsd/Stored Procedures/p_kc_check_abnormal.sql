-- ==========================================================================================
-- 2012/08/13 增加繳款日期條件
-- ==========================================================================================
CREATE   PROCEDURE [kcsd].[p_kc_check_abnormal] @pm_strt_date datetime, @pm_stop_date datetime 
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_expt_date	datetime,
	@wk_perd_no	int,
	@wk_expt_last	int,		/* Last */
	@wk_pay_last	int,		/* Last */
	@wk_expt_fee	int,		/* This */
	@wk_pay_fee	int		/* This */

CREATE TABLE #tmp_check_abnormal
(kc_case_no	varchar(10),
kc_perd_no	int
)

SELECT	@wk_case_no=NULL, @wk_expt_date=NULL

DECLARE	cursor_expt_date	CURSOR
FOR	SELECT	kc_case_no, kc_expt_date
	FROM	kcsd.kc_loanpayment
             WHERE kc_case_no in (SELECT kc_case_no FROM kcsd.kc_loanpayment WHERE kc_pay_date BETWEEN @pm_strt_date AND @pm_stop_date)
	GROUP BY kc_case_no, kc_expt_date
	HAVING COUNT(kc_case_no) > 1

OPEN cursor_expt_date
FETCH NEXT FROM cursor_expt_date INTO @wk_case_no, @wk_expt_date


WHILE (@@FETCH_STATUS = 0)
BEGIN	
	SELECT	@wk_expt_fee = 0, @wk_pay_fee = 0,
		@wk_expt_last = NULL, @wk_pay_last = NULL

	DECLARE	cursor_perd_no	CURSOR
	FOR	SELECT	kc_perd_no
		FROM	kcsd.kc_loanpayment
		WHERE	kc_case_no = @wk_case_no
		AND	kc_expt_date = @wk_expt_date
		ORDER BY kc_expt_date, kc_perd_no

	OPEN cursor_perd_no
	FETCH NEXT FROM cursor_perd_no INTO @wk_perd_no
	WHILE (@@FETCH_STATUS = 0)
	BEGIN	

		SELECT	@wk_expt_fee = kc_expt_fee, @wk_pay_fee = kc_pay_fee
		FROM	kcsd.kc_loanpayment
		WHERE	kc_case_no = @wk_case_no
		AND	kc_perd_no = @wk_perd_no
		
		/* SELECT	@wk_case_no, @wk_perd_no, @wk_expt_date, @wk_expt_fee, @wk_pay_fee */

		IF	(@wk_expt_last IS NOT NULL AND @wk_pay_last IS NOT NULL)
		AND	( (@wk_expt_last - @wk_pay_last) <> @wk_expt_fee)
		BEGIN
			/* SELECT	@wk_case_no, @wk_perd_no */
			INSERT	#tmp_check_abnormal
				(kc_case_no, kc_perd_no)
			VALUES	(@wk_case_no, @wk_perd_no)
		END

		SELECT	@wk_expt_last = @wk_expt_fee,
			@wk_pay_last = @wk_pay_fee

		FETCH NEXT FROM cursor_perd_no INTO @wk_perd_no
	END

	DEALLOCATE	cursor_perd_no

	FETCH NEXT FROM cursor_expt_date INTO @wk_case_no, @wk_expt_date
END

SELECT	*
FROM	#tmp_check_abnormal

DEALLOCATE	cursor_expt_date
