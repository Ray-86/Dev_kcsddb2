-- ==========================================================================================
-- 20180227 計算催收轉法務
-- ==========================================================================================

CREATE PROCEDURE [kcsd].[p_kc_pushonhand_PtoL] @pm_strt_date datetime=NULL, @pm_stop_date datetime=NULL,@pm_area_code varchar(100)=NULL,@pm_run_code varchar(10)=NULL
AS
DECLARE	
	@wk_case_no			varchar(10),
	@wk_pusher_code		varchar(6),
	@wk_pusher_code1	varchar(6),
	@wk_strt_date		datetime,
	@wk_strt_date1		datetime,
	@wk_rema_amt		int,
	@wk_over_amt		int,
	@wk_break_amt		int,
	@wk_expt_amt		int,
	@wk_pay_sum			int,
	@wk_maxpay_date		datetime

CREATE TABLE #tmp_pushonhandPtoL
(
	kc_case_no			varchar(10),
	kc_pusher_code		varchar(6),
	kc_pusher_code1		varchar(6),
	kc_strt_date		datetime,
	kc_strt_date1		datetime,
	kc_rema_amt			int,
	kc_over_amt			int,
	kc_break_amt		int,
	kc_maxpay_date		datetime
)

--取委派資料
CREATE TABLE #tmp_pushonhandPtoL_overamt
(
	kc_case_no		varchar(10),
	kc_area_code	varchar(2),
	kc_area_desc	varchar(10),
	kc_pusher_code	varchar(6),
	kc_strt_date	smalldatetime,
	kc_close_date	smalldatetime,
	kc_over_amt		int,
	kc_pay_sum		int,
	kc_pay_sum1		int,
	kc_intr_sum		int,
	kc_break_sum	int,
	kc_delay_code	varchar(1),
	kc_cust_nameu	nvarchar(60),
	kc_emp_name		varchar(10),
	kc_loan_desc	varchar(6)
)

CREATE TABLE #tmp_pushscore
(
	kc_case_no	varchar(10),
	kc_pay_date	datetime,
	kc_pay_fee	int,
	kc_break_fee	int,
	kc_intr_fee	int,
	kc_pusher_code	varchar(6),
	kc_cust_nameu nvarchar(60),
	kc_emp_name varchar(10),
	kc_break_amt2	int,
	kc_break_over	int,
	kc_rece_amt int,
	kc_break_amts int,
	kc_strt_date datetime,
	kc_recog_amt int
)
Insert into #tmp_pushonhandPtoL_overamt EXEC kcsd.p_kc_pushonhand_push @pm_strt_date , @pm_stop_date	--催收委派統計
Insert into #tmp_pushscore EXEC kcsd.p_kc_pushscore @pm_strt_date , @pm_stop_date						--入賬統計 (只抓違約金)

DECLARE c1 CURSOR FOR
	--第一次派法務
	SELECT * FROM
	(SELECT p.kc_case_no,MIN(p.kc_strt_date) as kc_strt_date
		FROM kcsd.kc_pushassign p left join kcsd.kc_customerloan c on c.kc_case_no = p.kc_case_no
		WHERE p.kc_pusher_code LIKE 'L%'
		GROUP BY p.kc_case_no,kc_sales_code) S
	WHERE S.kc_strt_date between @pm_strt_date and @pm_stop_date
OPEN c1
FETCH NEXT FROM c1 INTO @wk_case_no,@wk_strt_date1
WHILE (@@FETCH_STATUS = 0)
BEGIN
	--取轉法務前催收
	SELECT	TOP 1 @wk_pusher_code = kc_pusher_code,@wk_strt_date = kc_strt_date
	FROM	kcsd.kc_pushassign
	WHERE	kc_case_no = @wk_case_no AND (kc_pusher_code LIKE 'P%' OR kc_pusher_code LIKE 'S%') AND kc_strt_date < @wk_strt_date1
	ORDER BY kc_strt_date DESC

	--取轉法務時 逾期金額、未繳餘額、違約金
	SELECT 
	@wk_over_amt = (SELECT ISNULL(SUM(kc_expt_fee), 0) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_expt_date < @wk_strt_date1 AND kc_perd_no < 50) -
				   (SELECT	ISNULL(SUM(kc_pay_fee), 0) FROM	kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND	kc_pay_date < @wk_strt_date1),
	@wk_rema_amt = (SELECT	ISNULL(SUM(ISNULL(kc_expt_fee, 0)), 0) FROM	kcsd.kc_loanpayment WHERE	kc_case_no = c.kc_case_no AND kc_perd_no < 50) -
					(SELECT	ISNULL(SUM(kc_pay_fee), 0) FROM	kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND	kc_pay_date < @wk_strt_date1),
	@wk_break_amt = CASE WHEN 
					(SELECT	ISNULL(ROUND(SUM(kc_expt_fee*DATEDIFF(day,kc_expt_date, @wk_strt_date1) )/1000.0, 0),0) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date IS NULL AND kc_expt_date < @wk_strt_date1 AND kc_expt_fee > 0)+
					(SELECT	ISNULL(ROUND(SUM(kc_expt_fee*DATEDIFF(day,kc_expt_date, kc_pay_date) )/1000.0, 0),0) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date IS NOT NULL AND kc_expt_date < kc_pay_date AND kc_expt_fee > 0) -
					(SELECT	ISNULL(SUM(kc_break_fee), 0) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND	kc_pay_date < @wk_strt_date1)
					> 0 THEN 
					(SELECT	ISNULL(ROUND(SUM(kc_expt_fee*DATEDIFF(day,kc_expt_date, @wk_strt_date1) )/1000.0, 0),0) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date IS NULL AND kc_expt_date < @wk_strt_date1 AND kc_expt_fee > 0)+
					(SELECT	ISNULL(ROUND(SUM(kc_expt_fee*DATEDIFF(day,kc_expt_date, kc_pay_date) )/1000.0, 0),0) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date IS NOT NULL AND kc_expt_date < kc_pay_date AND kc_expt_fee > 0) -
					(SELECT	ISNULL(SUM(kc_break_fee), 0) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND	kc_pay_date < @wk_strt_date1)
					ELSE 0 END
	FROM kcsd.kc_customerloan c
	WHERE kc_case_no = @wk_case_no

	--目前最後繳款日
	SELECT @wk_maxpay_date = MAX(kc_pay_date) FROM kcsd.kc_loanpayment WHERE kc_case_no = @wk_case_no

	INSERT #tmp_pushonhandPtoL (kc_case_no,kc_pusher_code,kc_pusher_code1,kc_strt_date,kc_strt_date1,kc_rema_amt,kc_over_amt,kc_break_amt,kc_maxpay_date)
	VALUES (@wk_case_no,@wk_pusher_code,'L',@wk_strt_date,@wk_strt_date1,@wk_rema_amt,@wk_over_amt,@wk_break_amt,@wk_maxpay_date)

FETCH NEXT FROM c1 INTO @wk_case_no,@wk_strt_date1
END
CLOSE c1
DEALLOCATE c1

IF	@pm_run_code = 'EXECUTE'
BEGIN
	DECLARE @wk_datacount int
	SELECT @wk_datacount = count(*) from kcsd.kc_pushonhand_PtoL where kc_push_date = convert(varchar(6),@pm_strt_date,112)
	IF @wk_datacount = 0
		BEGIN
		Insert into kcsd.kc_pushonhand_PtoL
		SELECT convert(varchar(6),@pm_strt_date,112) as kc_push_date,c.kc_area_code,c.kc_prod_type,sum(p.kc_rema_amt) as kc_rema_amt
		FROM	#tmp_pushonhandPtoL p left join kcsd.kc_customerloan c on c.kc_case_no = p.kc_case_no
		GROUP BY c.kc_pusher_code,c.kc_area_code,c.kc_prod_type
		ORDER by c.kc_pusher_code,c.kc_area_code,c.kc_prod_type
	END
	
END
ELSE
BEGIN

	SELECT * from 
		(SELECT kc_pusher_code,SUM(kc_over_amt) as kc_over_sum,SUM(kc_pay_sum)-SUM(kc_intr_sum) as kc_recover_sum,SUM(kc_break_sum) as kc_break_sum from #tmp_pushonhandPtoL_overamt where kc_delay_code <> 'P' group by kc_pusher_code) as ss
		left join (select c.kc_area_code,c.kc_prod_type,c.kc_push_sort,c.kc_sales_code,c.kc_case_no,c.kc_cust_nameu,p.kc_pusher_code,sum(p.kc_rema_amt) as kc_rema_amt,sum(p.kc_over_amt) as kc_over_amt,sum(p.kc_break_amt) as kc_break_amt from #tmp_pushonhandPtoL p left join kcsd.kc_customerloan c on c.kc_case_no = p.kc_case_no group by c.kc_area_code,c.kc_prod_type,c.kc_push_sort,c.kc_sales_code,c.kc_case_no,c.kc_cust_nameu,p.kc_pusher_code) as dd on dd.kc_pusher_code = ss.kc_pusher_code
		left join (select kc_pusher_code,sum(kc_break_fee) as kc_break_sum1,sum(kc_rece_amt) as kc_rece_amt,sum(kc_break_amts)as kc_break_amts from #tmp_pushscore group by  kc_pusher_code) as cc on cc.kc_pusher_code = ss.kc_pusher_code
	ORDER BY ss.kc_pusher_code

		--SELECT kc_pusher_code,SUM(kc_over_amt) as kc_over_sum,SUM(kc_pay_sum)-SUM(kc_intr_sum) as kc_recover_sum,SUM(kc_break_sum) as kc_break_sum from #tmp_pushonhandPtoL_overamt where kc_delay_code <> 'P' group by kc_pusher_code
		

	/*
	SELECT	c.kc_area_code,c.kc_prod_type,p.*,c.kc_push_sort,c.kc_sales_code,c.kc_cust_nameu,ss.kc_over_sum,ss.kc_recover_sum,ss.kc_break_sum
	FROM	#tmp_pushonhandPtoL p left join kcsd.kc_customerloan c on c.kc_case_no = p.kc_case_no
							  left join (SELECT kc_pusher_code,SUM(kc_over_amt) as kc_over_sum,SUM(kc_pay_sum)-SUM(kc_intr_sum) as kc_recover_sum,SUM(kc_break_sum) as kc_break_sum from #tmp_pushonhandPtoL_overamt where kc_delay_code <> 'P' group by kc_pusher_code) ss on ss.kc_pusher_code = p.kc_pusher_code
	ORDER BY p.kc_pusher_code
	*/
END

DROP TABLE #tmp_pushonhandPtoL
DROP TABLE #tmp_pushonhandPtoL_overamt
DROP TABLE #tmp_pushscore