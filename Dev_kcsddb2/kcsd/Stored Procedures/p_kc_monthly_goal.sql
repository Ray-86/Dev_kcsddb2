CREATE PROCEDURE [kcsd].[p_kc_monthly_goal]
	@pm_perd_year int = 2002, @pm_perd_month int = 11
AS

DECLARE	@wk_perd_strt	datetime,
	@wk_perd_stop	datetime,
	@wk_strt_char	char(1),
	@wk_stop_char	char(1)

CREATE TABLE #tmp_goal
(
	kc_comp_char	varchar(2),
	kc_sales_code	varchar(6),
	kc_expt_cnt	int,	/* └│ª¼Áº╝ã */
	kc_expt_fee	int,	/* └│ª¼¬¸├B */

	kc_real_cnt	int,	/* ╣Ûª¼Áº╝ã */

	kc_real_fee	int	/* ╣Ûª¼¬¸├B */
)

/* ¿·▒o¡nªCñJ¡p║Ô¬║ñ¢Ñq */
SELECT	@wk_strt_char = kc_strt_char, @wk_stop_char = kc_stop_char
FROM	kcsd.kc_syscontrol

/* ¡p║ÔÂ}®l╗PÁ▓º¶ñÚ┤┴ */
SELECT	@wk_perd_strt = CONVERT(char(2),@pm_perd_month) + '/1/' + CONVERT(char(4),@pm_perd_year)
SELECT	@wk_perd_stop = DATEADD(MINUTE,-1,DATEADD(MONTH,1, @wk_perd_strt))



/* Ñ■│í └│ª¼ */
INSERT	#tmp_goal
SELECT	c.kc_comp_char2, c.kc_sales_code,COUNT(distinct c.kc_case_no), ISNULL(SUM(p.kc_expt_fee),0),0,0
FROM	kcsd.kc_customerloan c, kcsd.kc_loanpayment p
WHERE	c.kc_case_no = p.kc_case_no
AND	p.kc_expt_date <= @wk_perd_stop
AND	(p.kc_pay_date = NULL OR p.kc_pay_date>=@wk_perd_strt)

/*AND	c.kc_comp_char2 BETWEEN 'B' AND 'P'*/
AND	c.kc_comp_char2 BETWEEN @wk_strt_char AND @wk_stop_char
/* AND	(c.kc_accu_flag=NULL OR c.kc_accu_flag NOT IN ('C','K','L')) */
GROUP BY c.kc_comp_char2, c.kc_sales_code

/* Ñ■│í ╣Ûª¼ */
INSERT	#tmp_goal
SELECT	c.kc_comp_char2, c.kc_sales_code, 0,0,COUNT(distinct c.kc_case_no), ISNULL(SUM(p.kc_pay_fee),0)
FROM	kcsd.kc_customerloan c, kcsd.kc_loanpayment p
WHERE	c.kc_case_no = p.kc_case_no
AND	p.kc_expt_date <= @wk_perd_stop

AND	p.kc_pay_date BETWEEN @wk_perd_strt AND @wk_perd_stop

AND	c.kc_comp_char2 BETWEEN @wk_strt_char AND @wk_stop_char

/* AND	(c.kc_accu_flag=NULL OR c.kc_accu_flag NOT IN ('C','K','L')) */
GROUP BY c.kc_comp_char2, c.kc_sales_code

/* Clear old data */
DELETE
FROM	kcsd.kc_monthgoal
WHERE	kc_perd_year = @pm_perd_year
AND	kc_perd_month= @pm_perd_month

INSERT	kcsd.kc_monthgoal

SELECT	@pm_perd_year, @pm_perd_month, t.kc_comp_char, t.kc_sales_code, 
			SUM(t.kc_expt_cnt),SUM(t.kc_expt_fee),
			SUM(t.kc_real_cnt),SUM(t.kc_real_fee)
FROM	#tmp_goal t
GROUP BY t.kc_comp_char, t.kc_sales_code
