CREATE PROCEDURE [kcsd].[p_kc_updateloanstatus_closed] AS
/*
targe: status C, E, X

Status:
N: Às©Û«ã
C: ñw▓M,½¦Á▓«Î
D: ╣O┤┴
E: ╣O┤┴Á▓▓M (Ñ¢┤┴╣O┤┴ >= 2 ¡ËñÙ)
G: Good
X: Á▓«Î
*/
DECLARE	@wk_case_no		varchar(10),
	@wk_loan_stat		char(1),
	@wk_over_count		int,
	@wk_expt_count		int,
	@wk_over_count_org	int,
	@wk_pay_count		int,
	@wk_pay_count_org	int,
	@wk_dday_count		int,	/* ╣O┤┴ñÙ╝ã */
	@wk_dday_count_org	int,
	@wk_dday_date		datetime,/* ╣O┤┴░_®lñÚ */
	@wk_dday_date_org	datetime,
	@wk_perd_fee		int,
	@wk_over_amt		int,	/* ╣O┤┴¬¸├B */
	@wk_over_amt_org	int,
	@wk_break_amt		int,	/* ╣H¼¨¬¸ */
	@wk_break_amt_org	int,	
	@wk_break_amt_m		int,

	@wk_rema_amt		int,	/* │Ð¥l¬¸├B */
	@wk_rema_amt_org	int,

	@wk_apply_stat		char(1)	/* «Í¡Ò/Ñ╝«Í¡Ò */



SELECT	@wk_expt_count = 0, 
	@wk_over_count = 0, @wk_over_count_org = 0,

	@wk_pay_count = 0, @wk_pay_count_org = 0,
	@wk_dday_count = 0, @wk_dday_count_org = 0,
	@wk_over_amt = 0, @wk_break_amt = 0,	@wk_break_amt_m = 0,
	@wk_rema_amt = 0,

	@wk_dday_date = NULL,
	@wk_apply_stat = NULL

DECLARE	cursor_case_no	CURSOR
FOR	SELECT	kc_case_no, kc_loan_stat
	FROM	kcsd.kc_customerloan
	WHERE	kc_loan_stat = 'X'
	OR	kc_loan_stat = 'C'
	OR	kc_loan_stat = 'E'

OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no, @wk_loan_stat


WHILE (@@FETCH_STATUS = 0)
BEGIN
	/* ¡p║Ô╣Û╗┌╣O┤┴┤┴╝ã, delay ñÐ╝ã, ñ╬¬¸├B */
	SELECT	@wk_over_count=COUNT(kc_case_no),
		@wk_dday_date = MIN(kc_expt_date),
		@wk_over_amt = SUM(kc_expt_fee)
	FROM	kcsd.kc_loanpayment
	WHERE	kc_case_no = @wk_case_no
	AND	kc_pay_date = NULL
	AND	kc_expt_date < GETDATE()

	/* ¡p║Ô╣Û╗┌├║┤┌┤┴╝ã */
	SELECT	@wk_pay_count=COUNT(kc_case_no)
	FROM	kcsd.kc_loanpayment
	WHERE	kc_case_no = @wk_case_no
	AND	kc_pay_date <> NULL

	/* ¡p║Ô│Ð¥l¬¸├B */
	SELECT	@wk_rema_amt = SUM(kc_expt_fee)
	FROM	kcsd.kc_loanpayment
	WHERE	kc_case_no = @wk_case_no
	AND	kc_pay_date = NULL	

	SELECT	@wk_dday_count = DATEDIFF(month,ISNULL(@wk_dday_date,GETDATE()),GETDATE())

	IF	@wk_dday_count < 0
		SELECT	@wk_dday_count = 0

	/* ¡p║Ô╣H¼¨¬¸ */
	SELECT	@wk_perd_fee = kc_perd_fee
	FROM	kcsd.kc_customerloan
	WHERE	kc_case_no = @wk_case_no

	SELECT	@wk_break_amt_m = ROUND(@wk_perd_fee*0.02,0)
	SELECT	@wk_break_amt = @wk_break_amt_m*(@wk_dday_count+@wk_dday_count-@wk_over_count+1)*@wk_over_count/2.0

	/* ¿·▒o¡ýª│╣O┤┴┤┴╝ãÁÑ©Û«ã */
	SELECT	@wk_over_count_org = ISNULL(kc_over_count,0),
		@wk_pay_count_org = ISNULL(kc_pay_count,0),
		@wk_dday_date_org = kc_dday_date,
		@wk_dday_count_org = ISNULL(kc_dday_count,0),
		@wk_over_amt_org = ISNULL(kc_over_amt,0),
		@wk_break_amt_org = ISNULL(kc_break_amt,0),
		@wk_rema_amt_org = ISNULL(kc_rema_amt,0)
	FROM	kcsd.kc_customerloan
	WHERE	kc_case_no = @wk_case_no

	/* º¾Às╣O┤┴▓╬¡p */	
/*
	IF	(@wk_over_count <> @wk_over_count_org)
	OR	(@wk_pay_count <> @wk_pay_count_org)
	OR	(@wk_dday_date <> @wk_dday_date_org)
	OR	(@wk_dday_count <> @wk_dday_count_org)
	OR	(@wk_over_amt <> @wk_over_amt_org)
	OR	(@wk_break_amt <> @wk_break_amt_org)
	OR	(@wk_rema_amt <> @wk_rema_amt_org)

	UPDATE	kcsd.kc_customerloan
	SET	kc_over_count = @wk_over_count,
		kc_pay_count = @wk_pay_count,
		kc_dday_date = @wk_dday_date,
		kc_dday_count = @wk_dday_count,
		kc_over_amt = @wk_over_amt,
		kc_break_amt = @wk_break_amt,
		kc_rema_amt = @wk_rema_amt
	WHERE	kc_case_no = @wk_case_no
*/	

	IF	@wk_over_count > 0	/* ╣O┤┴ */

	BEGIN		
		SELECT	@wk_loan_stat = 'D'

		SELECT	@wk_case_no
/*
		UPDATE	kcsd.kc_customerloan

		SET	kc_loan_stat = @wk_loan_stat
		WHERE	kc_case_no = @wk_case_no

*/
	END
	
	FETCH NEXT FROM cursor_case_no INTO @wk_case_no, @wk_loan_stat
END

DEALLOCATE	cursor_case_no
