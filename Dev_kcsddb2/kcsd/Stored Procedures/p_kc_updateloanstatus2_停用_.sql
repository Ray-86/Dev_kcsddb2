CREATE PROCEDURE [kcsd].[p_kc_updateloanstatus2(停用)] AS
/*
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
	@wk_pay_count2		int,	/* ñ└┤┴Áº╝ã */
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
	@wk_cloan_amt		int,	/* ¡╔ÂU¬¸├B */


	@wk_apply_stat		char(1)	/* «Í¡Ò/Ñ╝«Í¡Ò */


SELECT	@wk_expt_count = 0, 
	@wk_over_count = 0, @wk_over_count_org = 0,

	@wk_pay_count = 0, @wk_pay_count_org = 0,
	@wk_dday_count = 0, @wk_dday_count_org = 0,
	@wk_over_amt = 0, @wk_break_amt = 0,	@wk_break_amt_m = 0,
	@wk_rema_amt = 0, @wk_cloan_amt = 0,
	@wk_dday_date = NULL,
	@wk_apply_stat = NULL

/*
UPDATE	kcsd.kc_customerloan2
SET	kc_loan_stat = 'N',
	kc_over_count = 0, kc_pay_count = 0
WHERE	kc_loan_stat = NULL
*/

DECLARE	cursor_case_no	CURSOR
FOR	SELECT	kc_case_no, kc_loan_stat
	FROM	kcsd.kc_customerloan2
	WHERE	kc_loan_type = 'D'
	AND	kc_loan_stat <> 'X'
	AND	kc_loan_stat <> 'C'
	AND	kc_loan_stat <> 'E'
	AND	kc_loan_stat <> 'R'
	AND	kc_loan_stat <> 'A'
	

OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no, @wk_loan_stat


WHILE (@@FETCH_STATUS = 0)
BEGIN
	/* ¡p║Ô╣Û╗┌╣O┤┴┤┴╝ã, delay ñÐ╝ã, ñ╬¬¸├B */
	SELECT	@wk_over_count=COUNT(kc_case_no),
		@wk_dday_date = MIN(kc_expt_date),
		@wk_over_amt = ISNULL(SUM(kc_expt_fee),0)
	FROM	kcsd.kc_loanpayment2
	WHERE	kc_case_no = @wk_case_no
	AND	kc_pay_date = NULL
	AND	kc_expt_date < GETDATE()

	/* ¡p║Ô╣Û╗┌├║┤┌┤┴╝ã */
	SELECT	@wk_pay_count=COUNT(kc_case_no)
	FROM	kcsd.kc_loanpayment2
	WHERE	kc_case_no = @wk_case_no
	AND	kc_pay_date <> NULL

	/* ¡p║Ô│Ð¥l¬¸├B */

	SELECT	@wk_rema_amt = ISNULL(SUM(kc_expt_fee),0)
	FROM	kcsd.kc_loanpayment2
	WHERE	kc_case_no = @wk_case_no
	AND	kc_pay_date = NULL	

	/* ¡p║Ô¡╔ÂU¬¸├Bñº¥l├B */
	SELECT	@wk_cloan_amt = ISNULL(SUM(ISNULL(kc_item_out,0)-ISNULL(kc_item_in,0)),0)
	FROM	kcsd.kc_caseloan
	WHERE	kc_case_no = @wk_case_no
	
	/* ¡Yª│¡╔ÂU½h┤┴╝ã+1,ÑB¬¸├BÑ[¿ý¥l├Bññ */
	IF	@wk_cloan_amt > 0
		SELECT	@wk_over_count = @wk_over_count + 1,
			@wk_rema_amt = @wk_rema_amt + @wk_cloan_amt

	/* ¡p║Ô╣H¼¨ñÐ╝ã */
	SELECT	@wk_dday_count = DATEDIFF(month,ISNULL(@wk_dday_date,GETDATE()),GETDATE())

	IF	@wk_dday_count < 0
		SELECT	@wk_dday_count = 0

	/* ¡p║Ô╣H¼¨¬¸ */
	SELECT	@wk_perd_fee = kc_perd_fee
	FROM	kcsd.kc_customerloan2
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
	FROM	kcsd.kc_customerloan2
	WHERE	kc_case_no = @wk_case_no

	/* º¾Às╣O┤┴▓╬¡p */	
	IF	(@wk_over_count <> @wk_over_count_org)
	OR	(@wk_pay_count <> @wk_pay_count_org)
	OR	(@wk_dday_date <> @wk_dday_date_org)
	OR	(@wk_dday_count <> @wk_dday_count_org)
	OR	(@wk_over_amt <> @wk_over_amt_org)
	OR	(@wk_break_amt <> @wk_break_amt_org)
	OR	(@wk_rema_amt <> @wk_rema_amt_org)

	UPDATE	kcsd.kc_customerloan2
	SET	kc_over_count = @wk_over_count,
		kc_pay_count = @wk_pay_count,
		kc_dday_date = @wk_dday_date,
		kc_dday_count = @wk_dday_count,
		kc_over_amt = @wk_over_amt,
		kc_break_amt = @wk_break_amt,
		kc_rema_amt = @wk_rema_amt
	WHERE	kc_case_no = @wk_case_no
	

	IF	@wk_over_count > 0	/* ╣O┤┴ */

	BEGIN		
		IF	@wk_loan_stat <> 'D'
		BEGIN
			SELECT	@wk_loan_stat = 'D'



			UPDATE	kcsd.kc_customerloan2

			SET	kc_loan_stat = @wk_loan_stat
			WHERE	kc_case_no = @wk_case_no

		END
	END
	ELSE	/* Ñ╝ñÝ┤┌ (@wk_over_count=0) */

	BEGIN
		/* ¡p║Ô¼Oº_┴┘ª│Ñ╝¿ý┤┴¬║ñ└┤┴ */
		SELECT	@wk_expt_count=COUNT(kc_case_no)

		FROM	kcsd.kc_loanpayment2
		WHERE	kc_case_no = @wk_case_no
		AND	kc_pay_date = NULL
		AND	kc_expt_fee > 0	

		IF	@wk_expt_count = 0 /* ñwÑI▓M */
		BEGIN
			/* ╣O┤┴Á▓▓M */
			IF	@wk_dday_count_org >= 2
			BEGIN
				SELECT	@wk_loan_stat = 'E'


				UPDATE	kcsd.kc_customerloan2
				SET	kc_loan_stat = @wk_loan_stat
				WHERE	kc_case_no = @wk_case_no
			END

			ELSE
			BEGIN
				SELECT	@wk_pay_count2 = COUNT(kc_case_no)
				FROM	kcsd.kc_loanpayment2
				WHERE	kc_case_no = @wk_case_no

				IF	@wk_pay_count2 > 0	/* KC020427:┴ÎºKÑ╝Ñ═¼÷┐²ªËÁ▓«Î */
				BEGIN
					SELECT	@wk_loan_stat = 'C'


					UPDATE	kcsd.kc_customerloan2
					SET	kc_loan_stat = @wk_loan_stat

					WHERE	kc_case_no = @wk_case_no
				END
			END
		END


		ELSE	/* ┴┘ª│Ñ╝¿ý┤┴¬║ñ└┤┴ */
		IF	@wk_loan_stat <> 'G'
		BEGIN

			UPDATE	kcsd.kc_customerloan2



			SET	kc_loan_stat = 'G'
			WHERE	kc_case_no = @wk_case_no
		END
	END
	
	FETCH NEXT FROM cursor_case_no INTO @wk_case_no, @wk_loan_stat
END

DEALLOCATE	cursor_case_no
