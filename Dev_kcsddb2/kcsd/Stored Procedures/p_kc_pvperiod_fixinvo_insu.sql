CREATE   PROCEDURE [kcsd].[p_kc_pvperiod_fixinvo_insu]
	@pm_case_no varchar(10),
	@pm_perd_no int,
	@pm_proc_amt int OUTPUT
AS

DECLARE	@wk_over_insu int

-- 抓溢開保費
IF	EXISTS	(SELECT	'*'
		FROM	kcsd.kc_zzfix_invo
		WHERE	kc_case_no = @pm_case_no
		AND	(kc_perd_no IS NULL
			OR kc_perd_no = @pm_perd_no)
		)
BEGIN
	SELECT	@wk_over_insu = 0

	-- 減去溢繳手續費
	SELECT	@wk_over_insu = kc_invo_diff
	FROM	kcsd.kc_zzfix_invo
	WHERE	kc_case_no = @pm_case_no


	SELECT	@pm_proc_amt = @pm_proc_amt - @wk_over_insu

	UPDATE	kcsd.kc_zzfix_invo
	SET	kc_perd_no = @pm_perd_no
	WHERE	kc_case_no = @pm_case_no
	AND	kc_perd_no IS NULL		-- KC: 12/19/2009
END
