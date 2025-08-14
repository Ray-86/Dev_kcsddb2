-- ==========================================================================================
-- 2014/02/05 催收已估車變成正常時亦不回收(取消Px9)
-- 2013/12/18 逾3案件(Sx) 狀態已估車變成正常時亦不回收
-- 2013/04/19 逾3案件(Px9) 狀態變成正常時亦不回收
-- 01/15/08 結束日改為當日凌晨
-- 07/11/07 KC: 恢復法務改派。0609修改應為正確, 06227應為怪異現象特例,不考慮
-- 06/22/07 KC: 0609修改法務不改派doens't work. 修改cursor loop, 不考慮法務,
--		另寫程式處理法務
-- 06/09/07 KC: 繳款恢復正常但未結案, 繼續留在法務L, 不收回	
-- 01/22/07 KC: add recycle for L%
-- 04/22/06 KC: 改為每日收回指派, 不區分 M0,M1
-- Batch: M0, M1 結束指派用
-- 	@pm_delay_code:	選擇 M0/M1
-- 	@pm_run_code:	選擇 try run 是或實際執行
-- ==========================================================================================
CREATE                      PROCEDURE [kcsd].[p_kc_pushassign_close]
	@pm_run_code varchar(10)=NULL,
	@pm_delay_code varchar(4)=NULL
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_strt_date	datetime,
	@wk_close_date	datetime,		-- 指派結束日
	@wk_perd_strt	datetime,		/* 本月1日 */
	@wk_perd_lstrt	datetime,		/* 上月第一天 (M1基準日) */
	@wk_perd_lstop	datetime,		/* 上月最後一天 */
	@wk_lpay_date	datetime,
	@wk_invo_date	datetime,
	@wk_delay_code	varchar(4),
	@wk_delay_stat	varchar(4),
	@wk_over_amt	int,			/* 逾期金額 */
	@wk_arec_amt	int,			/* 未繳金額 */
	@wk_dday_date	datetime,		/* dummy for p_kc_getoveramt */
	@wk_loan_stat	varchar(4),
	@wk_pusher_code	varchar(10),
	@wk_fig0_amt int

SELECT	@wk_case_no=NULL

/* 抓上月第一天/最後一天 */
SELECT	@wk_perd_strt =  DATEADD(mm, DATEDIFF(mm,0,getdate()), 0)
SELECT	@wk_perd_lstrt = DATEADD(month, -1, @wk_perd_strt)
SELECT	@wk_perd_lstop = DATEADD(day, -1, @wk_perd_strt)

-- 取得結束日凌晨 (今天)
SELECT	@wk_close_date = CONVERT(varchar(20), GETDATE(), 23) 

CREATE TABLE #tmp_assignclose
(
kc_case_no	varchar(10) not null,
kc_delay_stat	varchar(4) not null,
kc_strt_date	datetime not null,
kc_lpay_date	datetime null,
kc_invo_date	datetime null,
kc_fig0_amt	int,
kc_close_type	varchar(10)
)

-- 不管何時結束, 每天計算
DECLARE	cursor_case_no	CURSOR
FOR	SELECT	c.kc_case_no
	FROM	kcsd.kc_customerloan c, kcsd.kc_pushassign p
	WHERE	p.kc_stop_date IS NULL
	AND	c.kc_case_no = p.kc_case_no
	AND	(c.kc_loan_stat = 'G'
		OR c.kc_loan_stat = 'C'
		OR c.kc_loan_stat = 'E')
	AND	c.kc_pusher_code IS NOT NULL
--	AND 	c.kc_case_no <> '1412462' --此件暫時不回收 20150309
	ORDER BY c.kc_case_no

OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_lpay_date = NULL,@wk_invo_date = NULL, @wk_strt_date = NULL,
		@wk_pusher_code = NULL, @wk_loan_stat = NULL

	SELECT	@wk_strt_date = kc_strt_date,
		@wk_delay_code = kc_delay_code
	FROM	kcsd.kc_pushassign
	WHERE	kc_case_no = @wk_case_no
	AND	kc_stop_date IS NULL

	IF	@wk_delay_code = 'M0' OR @wk_delay_code = 'MX'
		SELECT	@wk_delay_stat = 'M0'
	ELSE
		SELECT	@wk_delay_stat = 'M1'

	--檢查是否是估車件
	--SELECT @wk_fig0_amt = Count(kc_case_no) from kcsd.kc_lawstatus where kc_case_no = @wk_case_no and kc_law_code ='M'
	SELECT @wk_fig0_amt = Count(*) from kcsd.kc_appraiseh WHERE kc_case_no = @wk_case_no and kc_appraise_stat = '50' 
	IF @wk_fig0_amt = 0
		SELECT @wk_fig0_amt = + Count(*) from kcsd.kc_loanpayment WHERE kc_rece_code = 'A2' AND kc_case_no = @wk_case_no

	-- 取得基本資料
	SELECT	@wk_pusher_code = kc_pusher_code, @wk_loan_stat = kc_loan_stat
	FROM	kcsd.kc_customerloan
	WHERE	kc_case_no = @wk_case_no

	-- 指派結束
	IF	@wk_loan_stat = 'C' OR 
		@wk_loan_stat = 'E' OR
		( @wk_loan_stat = 'G' AND @wk_pusher_code LIKE 'P%' AND @wk_fig0_amt = 0 ) OR
		( @wk_loan_stat = 'G' AND @wk_pusher_code LIKE 'S%' AND @wk_fig0_amt = 0 ) OR
		( @wk_loan_stat = 'G' AND @wk_pusher_code LIKE 'C%' AND @wk_fig0_amt = 0 )
	BEGIN
		/* 上月底前最後一次付款日*/
		SELECT	@wk_lpay_date = MAX(kc_pay_date)
		FROM	kcsd.kc_loanpayment
		WHERE	kc_case_no = @wk_case_no
		AND	kc_pay_date IS NOT NULL

		/*發票日*/
		SELECT	@wk_invo_date = MAX(kc_invo_date)
		FROM	kcsd.kc_loanpayment
		WHERE	kc_case_no = @wk_case_no
		AND	kc_invo_date IS NOT NULL

		INSERT	#tmp_assignclose
			(kc_case_no, kc_delay_stat, kc_strt_date, kc_lpay_date,kc_invo_date,kc_fig0_amt,kc_close_type)
		VALUES	(@wk_case_no, @wk_delay_stat, @wk_strt_date, @wk_lpay_date,@wk_invo_date,@wk_fig0_amt,'回收')

		/* 執行指派結束 */
		IF	@pm_run_code = 'EXECUTE'
		BEGIN
			UPDATE	kcsd.kc_pushassign
			SET	kc_stop_date = @wk_close_date,
				kc_updt_user = USER, kc_updt_date = GETDATE()
			WHERE	kc_case_no = @wk_case_no
			AND	kc_stop_date IS NULL

			UPDATE	kcsd.kc_customerloan
			SET	kc_pusher_code = NULL, kc_pusher_date = NULL,
				kc_delay_code = NULL
			WHERE	kc_case_no = @wk_case_no
		END
	END
	ELSE
	BEGIN
		INSERT	#tmp_assignclose
			(kc_case_no, kc_delay_stat, kc_strt_date, kc_lpay_date,kc_invo_date,kc_fig0_amt,kc_close_type)
		VALUES	(@wk_case_no, @wk_delay_stat, @wk_strt_date, @wk_lpay_date,@wk_invo_date,@wk_fig0_amt,'不回收')
	END

	FETCH NEXT FROM cursor_case_no INTO @wk_case_no
END

DEALLOCATE	cursor_case_no

IF	@pm_run_code = 'TEST'
BEGIN
	SELECT	t.*, c.kc_pusher_code, c.kc_loan_stat
	FROM	#tmp_assignclose t, kc_customerloan c
	WHERE	t.kc_case_no = c.kc_case_no
	ORDER BY c.kc_loan_stat, t.kc_delay_stat, t.kc_case_no
END

DROP TABLE #tmp_assignclose
