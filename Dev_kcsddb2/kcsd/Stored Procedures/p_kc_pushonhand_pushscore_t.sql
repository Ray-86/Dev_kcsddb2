-- ==========================================================================================
-- 20170306 增加是否依分公司群組參數
-- 20170215 增加計算分數;增加拋轉月報TABLE功能
-- 20170210 修正計算錯誤
-- ==========================================================================================
--
--計算說明：
--1. 評分計算範圍：M0~M3回收金額比、M0~M3回收件數比
--2. 參考平均值預設目標 (一季後再評估)
--3. 依各階段回收工作效能分配個別項目得分比例
--4. 基本件數預設500件，按委派案件總數增減加權分數(25件=0.5分計算比例)
--5. 訂基本分數為70分，目標增減1%計算分數1分
--6. M0、M1超過目標不加分 (排除偏重催M0取分數而放棄M2-M3、減低M0件客訴)
--7. M2、M3件數過低時較可能發生回收0，可再討論是否追加評估
--8. M2、M3件數為0時，計算基本分數(不減分)，M2、M3上限100分
--評分項目		預設目標	得分比例	基本分數	1分/%
--M0回收金額比	90%			15%			70			1
--M1回收金額比	60%			15%		
--M2回收金額比	30%			15%		
--M3回收金額比	20%			15%
		
--M0回收件數比	90%			10%		
--M1回收件數比	70%			10%		
--M2回收件數比	40%			10%		
--M3回收件數比	30%			10%						
--委派件數		500									增減0.02 分/件


CREATE PROCEDURE [kcsd].[p_kc_pushonhand_pushscore_t] @pm_strt_date datetime=NULL, @pm_stop_date datetime=NULL	,@pm_area_code varchar(100)=NULL,@pm_run_code varchar(10)=NULL
AS

CREATE TABLE #tmp_pushonhand2
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

CREATE TABLE #tmp_pushonhand3
(
	kc_pusher_code	varchar(6),
	kc_area_code	varchar(2),
	kc_area_desc	varchar(10),
	kc_delay_code	varchar(1),
	kc_over_count	int,
	kc_pay_count	int,
	kc_close_count	int,
	kc_over_amt		int,
	kc_pay_sum		int,
	kc_pay_sum1		int,
	kc_intr_sum		int,
	kc_recover_sum	int,
	kc_break_sum	int,
	kc_amount_rate	float,
	kc_recover_rate	float,
	kc_amount_point	float,
	kc_amount_point1	float,
	kc_recover_point	float,
	kc_recover_point1	float,
	kc_scores_point	float,
	kc_scores_point1	float,
	kc_scores_point2	float,
	kc_scores_point3	float
)

CREATE TABLE #tmp_pushonhand4
(
	kc_pusher_code	varchar(6),
	kc_area_code	varchar(2),
	kc_area_desc	varchar(10),
	kc_delay_code	varchar(1),
	kc_over_count	int,
	kc_pay_count	int,
	kc_close_count	int,
	kc_over_amt		int,
	kc_pay_sum		int,
	kc_pay_sum1		int,
	kc_intr_sum		int,
	kc_recover_sum	int,
	kc_break_sum	int,
	kc_amount_rate	float,
	kc_recover_rate	float,
	kc_amount_point	float,
	kc_amount_point1	float,
	kc_recover_point	float,
	kc_recover_point1	float,
	kc_scores_point	float,
	kc_scores_point1	float,
	kc_scores_point2	float,
	kc_scores_point3	float
)

Insert into #tmp_pushonhand2 EXEC kcsd.p_kc_pushonhand_push @pm_strt_date,@pm_stop_date,@pm_area_code
--Insert into #tmp_pushonhand2 EXEC kcsd.p_kc_pushonhand_push '2017-02-01','2017-02-28',null

Insert into #tmp_pushonhand3 --依公司別GROUP
	SELECT  
	kc_pusher_code,
	#tmp_pushonhand2.kc_area_code,
	kct_area.kc_area_desc,
	kc_delay_code,
	COUNT(*) AS kc_over_count,
	SUM(CASE WHEN kc_pay_sum > 0 THEN 1 ELSE 0 END) AS kc_pay_count,
	SUM(CASE WHEN kc_close_date IS NOT NULL THEN 1 ELSE 0 END) AS kc_close_count,
	SUM(kc_over_amt) AS kc_over_amt,
	SUM(kc_pay_sum) AS kc_pay_sum,
	SUM(kc_pay_sum1) AS kc_pay_sum1,
	SUM(kc_intr_sum) AS kc_intr_sum,
	SUM(kc_pay_sum) - SUM(kc_intr_sum) AS kc_recover_sum,
	SUM(kc_break_sum) AS kc_break_sum,
	(SUM(kc_pay_sum) - SUM(kc_intr_sum)) * 1.0 / CASE WHEN SUM(kc_over_amt) = 0 THEN 1 ELSE SUM(kc_over_amt) END AS kc_amount_rate,
	SUM(CASE WHEN kc_pay_sum > 0 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS kc_recover_rate,
	0 AS kc_amount_point,
	0 AS kc_amount_point1,
	0 AS kc_recover_point,
	0 AS kc_recover_point1,
	0 AS kc_scores_point,
	0 AS kc_scores_point1,
	0 AS kc_scores_point2,
	0 AS kc_scores_point3
	FROM #tmp_pushonhand2
	LEFT JOIN kcsd.kct_area ON #tmp_pushonhand2.kc_area_code = kct_area.kc_area_code
	GROUP BY kc_pusher_code,#tmp_pushonhand2.kc_area_code,kct_area.kc_area_desc,kc_delay_code
	ORDER BY kc_pusher_code,#tmp_pushonhand2.kc_area_code,kct_area.kc_area_desc,kc_delay_code

Insert into #tmp_pushonhand4 --依催收代號GROUP
	SELECT  
	kc_pusher_code,
	'',
	'',
	kc_delay_code,
	COUNT(*) AS kc_over_count,
	SUM(CASE WHEN kc_pay_sum > 0 THEN 1 ELSE 0 END) AS kc_pay_count,
	SUM(CASE WHEN kc_close_date IS NOT NULL THEN 1 ELSE 0 END) AS kc_close_count,
	SUM(kc_over_amt) AS kc_over_amt,
	SUM(kc_pay_sum) AS kc_pay_sum,
	SUM(kc_pay_sum1) AS kc_pay_sum1,
	SUM(kc_intr_sum) AS kc_intr_sum,
	SUM(kc_pay_sum) - SUM(kc_intr_sum) AS kc_recover_sum,
	SUM(kc_break_sum) AS kc_break_sum,
	(SUM(kc_pay_sum) - SUM(kc_intr_sum)) * 1.0 / CASE WHEN SUM(kc_over_amt) = 0 THEN 1 ELSE SUM(kc_over_amt) END AS kc_amount_rate,
	SUM(CASE WHEN kc_pay_sum > 0 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS kc_recover_rate,
	0 AS kc_amount_point,
	0 AS kc_amount_point1,
	0 AS kc_recover_point,
	0 AS kc_recover_point1,
	0 AS kc_scores_point,
	0 AS kc_scores_point1,
	0 AS kc_scores_point2,
	0 AS kc_scores_point3
	FROM #tmp_pushonhand2
	LEFT JOIN kcsd.kct_area ON #tmp_pushonhand2.kc_area_code = kct_area.kc_area_code
	GROUP BY kc_pusher_code,kc_delay_code
	ORDER BY kc_pusher_code,kc_delay_code

--計算分數
DECLARE
	@wk_pusher_code		varchar(6),
	@wk_area_code 		varchar(2),
	@wk_count			float,
	@wk_m0_amount_rate	float,
	@wk_m1_amount_rate	float,
	@wk_m2_amount_rate	float,
	@wk_m3_amount_rate	float,
	@wk_m0_recover_rate	float,
	@wk_m1_recover_rate	float,
	@wk_m2_recover_rate	float,
	@wk_m3_recover_rate	float,
	@wk_point			float,
	@wk_m0_amount_point	float,
	@wk_m1_amount_point	float,
	@wk_m2_amount_point	float,
	@wk_m3_amount_point	float,
	@wk_m0_recover_point	float,
	@wk_m1_recover_point	float,
	@wk_m2_recover_point	float,
	@wk_m3_recover_point	float,
	------------------------------
	@wk_amount_point	float,
	@wk_recover_point	float,
	@wk_scores_point	float,
	@wk_scores_point1	float,
	-----------------------------------
	--設定目標
	@wk_mo_amount_target	float,
	@wk_m1_amount_target	float,
	@wk_m2_amount_target	float,
	@wk_m3_amount_target	float,
	@wk_mo_recover_target	float,
	@wk_m1_recover_target	float,
	@wk_m2_recover_target	float,
	@wk_m3_recover_target	float,
	
	@i	AS INT
	
SELECT @wk_mo_amount_target = 0.9;
SELECT @wk_m1_amount_target = 0.6;
SELECT @wk_m2_amount_target = 0.3;
SELECT @wk_m3_amount_target = 0.2;
SELECT @wk_mo_recover_target = 0.9;
SELECT @wk_m1_recover_target = 0.7;
SELECT @wk_m2_recover_target = 0.4;
SELECT @wk_m3_recover_target = 0.3;

DECLARE	cursor_pushonhand	CURSOR
FOR	
	SELECT DISTINCT kc_pusher_code,kc_area_code FROM #tmp_pushonhand3
OPEN cursor_pushonhand
FETCH NEXT FROM cursor_pushonhand INTO @wk_pusher_code,@wk_area_code
SET @i = 1

WHILE (@@FETCH_STATUS = 0)
BEGIN

	SELECT @wk_count = ISNULL(SUM(kc_over_count),0) FROM #tmp_pushonhand3 WHERE kc_delay_code <> 'P' AND kc_pusher_code = @wk_pusher_code AND kc_area_code = @wk_area_code
	SELECT @wk_m0_amount_rate = ISNULL(SUM(kc_amount_rate),0) FROM #tmp_pushonhand3 WHERE kc_delay_code = '0' AND kc_pusher_code = @wk_pusher_code AND kc_area_code = @wk_area_code
	SELECT @wk_m1_amount_rate = ISNULL(SUM(kc_amount_rate),0) FROM #tmp_pushonhand3 WHERE kc_delay_code = '1' AND kc_pusher_code = @wk_pusher_code AND kc_area_code = @wk_area_code
	SELECT @wk_m2_amount_rate = ISNULL(SUM(kc_amount_rate),0) FROM #tmp_pushonhand3 WHERE kc_delay_code = '2' AND kc_pusher_code = @wk_pusher_code AND kc_area_code = @wk_area_code
	SELECT @wk_m3_amount_rate = ISNULL(SUM(kc_amount_rate),0) FROM #tmp_pushonhand3 WHERE kc_delay_code = '3' AND kc_pusher_code = @wk_pusher_code AND kc_area_code = @wk_area_code
	SELECT @wk_m0_recover_rate = ISNULL(SUM(kc_recover_rate),0) FROM #tmp_pushonhand3 WHERE kc_delay_code = '0' AND kc_pusher_code = @wk_pusher_code AND kc_area_code = @wk_area_code
	SELECT @wk_m1_recover_rate = ISNULL(SUM(kc_recover_rate),0) FROM #tmp_pushonhand3 WHERE kc_delay_code = '1' AND kc_pusher_code = @wk_pusher_code AND kc_area_code = @wk_area_code
	SELECT @wk_m2_recover_rate = ISNULL(SUM(kc_recover_rate),0) FROM #tmp_pushonhand3 WHERE kc_delay_code = '2' AND kc_pusher_code = @wk_pusher_code AND kc_area_code = @wk_area_code
	SELECT @wk_m3_recover_rate = ISNULL(SUM(kc_recover_rate),0) FROM #tmp_pushonhand3 WHERE kc_delay_code = '3' AND kc_pusher_code = @wk_pusher_code AND kc_area_code = @wk_area_code
	
	SELECT @wk_m0_amount_point = CASE WHEN ((@wk_m0_amount_rate-@wk_mo_amount_target)*100)>0 THEN 0 ELSE (@wk_m0_amount_rate-@wk_mo_amount_target)*100 END + 70
	SELECT @wk_m1_amount_point = CASE WHEN ((@wk_m1_amount_rate-@wk_m1_amount_target)*100)>0 THEN 0 ELSE (@wk_m1_amount_rate-@wk_m1_amount_target)*100 END + 70
	SELECT @wk_m2_amount_point = CASE WHEN ((@wk_m2_amount_rate-@wk_m2_amount_target)*100+70)>100 THEN 100 ELSE (@wk_m2_amount_rate-@wk_m2_amount_target)*100+70 END
	SELECT @wk_m3_amount_point = CASE WHEN ((@wk_m3_amount_rate-@wk_m3_amount_target)*100+70)>100 THEN 100 ELSE (@wk_m3_amount_rate-@wk_m3_amount_target)*100+70 END
	SELECT @wk_m0_recover_point = CASE WHEN ((@wk_m0_recover_rate-@wk_mo_recover_target)*100)>0 THEN 0 ELSE (@wk_m0_recover_rate-@wk_mo_recover_target)*100 END + 70
	SELECT @wk_m1_recover_point = CASE WHEN ((@wk_m1_recover_rate-@wk_m1_recover_target)*100)>0 THEN 0 ELSE (@wk_m1_recover_rate-@wk_m1_recover_target)*100 END + 70
	SELECT @wk_m2_recover_point = CASE WHEN ((@wk_m2_recover_rate-@wk_m2_recover_target)*100+70)>100 THEN 100 ELSE (@wk_m2_recover_rate-@wk_m2_recover_target)*100+70 END
	SELECT @wk_m3_recover_point = CASE WHEN ((@wk_m3_recover_rate-@wk_m3_recover_target)*100+70)>100 THEN 100 ELSE (@wk_m3_recover_rate-@wk_m3_recover_target)*100+70 END

	UPDATE #tmp_pushonhand3 SET kc_amount_point = @wk_m0_amount_point ,kc_recover_point = @wk_m0_recover_point WHERE kc_pusher_code = @wk_pusher_code AND kc_area_code = @wk_area_code AND kc_delay_code = '0'
	UPDATE #tmp_pushonhand3 SET kc_amount_point = @wk_m1_amount_point ,kc_recover_point = @wk_m1_recover_point WHERE kc_pusher_code = @wk_pusher_code AND kc_area_code = @wk_area_code AND kc_delay_code = '1'
	UPDATE #tmp_pushonhand3 SET kc_amount_point = @wk_m2_amount_point ,kc_recover_point = @wk_m2_recover_point WHERE kc_pusher_code = @wk_pusher_code AND kc_area_code = @wk_area_code AND kc_delay_code = '2'
	UPDATE #tmp_pushonhand3 SET kc_amount_point = @wk_m3_amount_point ,kc_recover_point = @wk_m3_recover_point WHERE kc_pusher_code = @wk_pusher_code AND kc_area_code = @wk_area_code AND kc_delay_code = '3'
	UPDATE #tmp_pushonhand3 SET kc_amount_point = 0 ,kc_recover_point = 0 WHERE kc_pusher_code = @wk_pusher_code AND kc_area_code = @wk_area_code AND kc_delay_code = 'P'
	
	--計算得分
	SELECT @wk_amount_point  = sum(kc_amount_point) * 0.15 from #tmp_pushonhand3 WHERE kc_pusher_code = @wk_pusher_code AND kc_area_code = @wk_area_code AND kc_delay_code <> 'P'
	SELECT @wk_recover_point = sum(kc_recover_point)* 0.1  from #tmp_pushonhand3 WHERE kc_pusher_code = @wk_pusher_code AND kc_area_code = @wk_area_code AND kc_delay_code <> 'P'
	SELECT @wk_scores_point = @wk_amount_point  + @wk_recover_point + (@wk_count -500)/50
	SELECT @wk_scores_point1 = @wk_amount_point  + @wk_recover_point
	UPDATE #tmp_pushonhand3 SET kc_scores_point = @wk_scores_point WHERE kc_pusher_code = @wk_pusher_code AND kc_area_code = @wk_area_code
	UPDATE #tmp_pushonhand3 SET kc_scores_point1 = @wk_scores_point1 WHERE kc_pusher_code = @wk_pusher_code AND kc_area_code = @wk_area_code

	FETCH NEXT FROM cursor_pushonhand INTO @wk_pusher_code,@wk_area_code
END
DEALLOCATE	cursor_pushonhand

DECLARE	cursor_pushonhand	CURSOR
FOR	
	SELECT DISTINCT kc_pusher_code FROM #tmp_pushonhand4
OPEN cursor_pushonhand
FETCH NEXT FROM cursor_pushonhand INTO @wk_pusher_code
SET @i = 1

WHILE (@@FETCH_STATUS = 0)
BEGIN

	SELECT @wk_count = ISNULL(SUM(kc_over_count),0) FROM #tmp_pushonhand4 WHERE kc_delay_code <> 'P' AND kc_pusher_code = @wk_pusher_code
	SELECT @wk_m0_amount_rate = ISNULL(SUM(kc_amount_rate),0) FROM #tmp_pushonhand4 WHERE kc_delay_code = '0' AND kc_pusher_code = @wk_pusher_code
	SELECT @wk_m1_amount_rate = ISNULL(SUM(kc_amount_rate),0) FROM #tmp_pushonhand4 WHERE kc_delay_code = '1' AND kc_pusher_code = @wk_pusher_code
	SELECT @wk_m2_amount_rate = ISNULL(SUM(kc_amount_rate),0) FROM #tmp_pushonhand4 WHERE kc_delay_code = '2' AND kc_pusher_code = @wk_pusher_code
	SELECT @wk_m3_amount_rate = ISNULL(SUM(kc_amount_rate),0) FROM #tmp_pushonhand4 WHERE kc_delay_code = '3' AND kc_pusher_code = @wk_pusher_code
	SELECT @wk_m0_recover_rate = ISNULL(SUM(kc_recover_rate),0) FROM #tmp_pushonhand4 WHERE kc_delay_code = '0' AND kc_pusher_code = @wk_pusher_code
	SELECT @wk_m1_recover_rate = ISNULL(SUM(kc_recover_rate),0) FROM #tmp_pushonhand4 WHERE kc_delay_code = '1' AND kc_pusher_code = @wk_pusher_code
	SELECT @wk_m2_recover_rate = ISNULL(SUM(kc_recover_rate),0) FROM #tmp_pushonhand4 WHERE kc_delay_code = '2' AND kc_pusher_code = @wk_pusher_code
	SELECT @wk_m3_recover_rate = ISNULL(SUM(kc_recover_rate),0) FROM #tmp_pushonhand4 WHERE kc_delay_code = '3' AND kc_pusher_code = @wk_pusher_code
	
	SELECT @wk_m0_amount_point = CASE WHEN ((@wk_m0_amount_rate-@wk_mo_amount_target)*100)>0 THEN 0 ELSE (@wk_m0_amount_rate-@wk_mo_amount_target)*100 END + 70
	SELECT @wk_m1_amount_point = CASE WHEN ((@wk_m1_amount_rate-@wk_m1_amount_target)*100)>0 THEN 0 ELSE (@wk_m1_amount_rate-@wk_m1_amount_target)*100 END + 70
	SELECT @wk_m2_amount_point = CASE WHEN ((@wk_m2_amount_rate-@wk_m2_amount_target)*100+70)>100 THEN 100 ELSE (@wk_m2_amount_rate-@wk_m2_amount_target)*100+70 END
	SELECT @wk_m3_amount_point = CASE WHEN ((@wk_m3_amount_rate-@wk_m3_amount_target)*100+70)>100 THEN 100 ELSE (@wk_m3_amount_rate-@wk_m3_amount_target)*100+70 END
	SELECT @wk_m0_recover_point = CASE WHEN ((@wk_m0_recover_rate-@wk_mo_recover_target)*100)>0 THEN 0 ELSE (@wk_m0_recover_rate-@wk_mo_recover_target)*100 END + 70
	SELECT @wk_m1_recover_point = CASE WHEN ((@wk_m1_recover_rate-@wk_m1_recover_target)*100)>0 THEN 0 ELSE (@wk_m1_recover_rate-@wk_m1_recover_target)*100 END + 70
	SELECT @wk_m2_recover_point = CASE WHEN ((@wk_m2_recover_rate-@wk_m2_recover_target)*100+70)>100 THEN 100 ELSE (@wk_m2_recover_rate-@wk_m2_recover_target)*100+70 END
	SELECT @wk_m3_recover_point = CASE WHEN ((@wk_m3_recover_rate-@wk_m3_recover_target)*100+70)>100 THEN 100 ELSE (@wk_m3_recover_rate-@wk_m3_recover_target)*100+70 END

	UPDATE #tmp_pushonhand3 SET kc_amount_point1 = @wk_m0_amount_point ,kc_recover_point1 = @wk_m0_recover_point WHERE kc_pusher_code = @wk_pusher_code AND kc_delay_code = '0'
	UPDATE #tmp_pushonhand3 SET kc_amount_point1 = @wk_m1_amount_point ,kc_recover_point1 = @wk_m1_recover_point WHERE kc_pusher_code = @wk_pusher_code AND kc_delay_code = '1'
	UPDATE #tmp_pushonhand3 SET kc_amount_point1 = @wk_m2_amount_point ,kc_recover_point1 = @wk_m2_recover_point WHERE kc_pusher_code = @wk_pusher_code AND kc_delay_code = '2'
	UPDATE #tmp_pushonhand3 SET kc_amount_point1 = @wk_m3_amount_point ,kc_recover_point1 = @wk_m3_recover_point WHERE kc_pusher_code = @wk_pusher_code AND kc_delay_code = '3'
	UPDATE #tmp_pushonhand3 SET kc_amount_point1 = 0 ,kc_recover_point = 0 WHERE kc_pusher_code = @wk_pusher_code AND kc_delay_code = 'P'

	--計算得分
	SELECT @wk_amount_point  = sum(distinct kc_amount_point1) * 0.15 from #tmp_pushonhand3 WHERE kc_pusher_code = @wk_pusher_code AND kc_delay_code <> 'P'
	SELECT @wk_recover_point = sum(distinct kc_recover_point1)* 0.1  from #tmp_pushonhand3 WHERE kc_pusher_code = @wk_pusher_code AND kc_delay_code <> 'P'
	SELECT @wk_scores_point = @wk_amount_point  + @wk_recover_point + (@wk_count -500)/50
	SELECT @wk_scores_point1 = @wk_amount_point  + @wk_recover_point
	UPDATE #tmp_pushonhand3 SET kc_scores_point2 = @wk_scores_point WHERE kc_pusher_code = @wk_pusher_code
	UPDATE #tmp_pushonhand3 SET kc_scores_point3 = @wk_scores_point1 WHERE kc_pusher_code = @wk_pusher_code
	FETCH NEXT FROM cursor_pushonhand INTO @wk_pusher_code
END
DEALLOCATE	cursor_pushonhand
--select * from #tmp_pushonhand3 order by kc_pusher_code,kc_delay_code
--select * from #tmp_pushonhand4 order by kc_pusher_code,kc_delay_code
--SELECT distinct kc_delay_code,kc_amount_point1 from #tmp_pushonhand3 WHERE kc_pusher_code = 'P21' AND kc_delay_code <> 'P'
--SELECT sum(distinct kc_amount_point1) from #tmp_pushonhand3 WHERE kc_pusher_code = 'P21' AND kc_delay_code <> 'P'

IF	@pm_run_code = 'EXECUTE'
BEGIN
	
	DECLARE @wk_datacount int
	SELECT @wk_datacount = count(*) from kcsd.kc_pushonhand_push where kc_push_date = convert(varchar(6),@pm_strt_date,112)
	IF @wk_datacount = 0
		BEGIN
		Insert into kcsd.kc_pushonhand_push
		SELECT convert(varchar(6),@pm_strt_date,112) as kc_pusher_date,kc_area_code,kc_pusher_code,'' as kc_user_name,sum(kc_over_count) as kc_push_cnt,sum(kc_over_amt) as kc_over_amt,sum(kc_pay_count) as kc_pay_cnt,sum(kc_pay_sum) as kc_pay_sum,sum(kc_pay_sum1) as kc_pay_sum1,sum(kc_intr_sum) as kc_intr_sum,Sum([kc_pay_sum]-[kc_intr_sum]) as kc_pay_amt,sum(kc_break_sum) as kc_break_sum,sum(kc_close_count) as kc_close_cnt,sum(distinct kc_scores_point) as kc_scores_point,sum(distinct kc_scores_point1) as kc_scores_point1
		FROM #tmp_pushonhand3 
		WHERE kc_delay_code <> 'P'
		GROUP BY kc_pusher_code,kc_area_code
		ORDER BY kc_pusher_code,kc_area_code
	END

END
ELSE
BEGIN
	SELECT * FROM #tmp_pushonhand3 order by kc_pusher_code
END

DROP TABLE #tmp_pushonhand2
DROP TABLE #tmp_pushonhand3
DROP TABLE #tmp_pushonhand4
