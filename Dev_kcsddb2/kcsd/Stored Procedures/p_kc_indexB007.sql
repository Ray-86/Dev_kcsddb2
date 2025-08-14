-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [kcsd].[p_kc_indexB007]	@pm_pay_date varchar(8)
AS

--EXEC [kcsd].[p_kc_indexB007]	'2024-08','','',''

--CP核准
DECLARE @tmp_cpapply TABLE 
(	kc_comp_code	varchar(4),
    kc_prod_type	varchar(2),
	kc_str_date DATETIME,
	kc_stop_date DATETIME,
	total_cnt	int,			/* 總案件數量 */
	apply_P_cnt	int,			/* 核准案件數量 */
	datatype	varchar(2)			/* 月份 */
)
--利率(a/b),建檔數
DECLARE @tmp_case TABLE 
(	
	kc_comp_code	varchar(4),
    kc_prod_type	varchar(2),
	kc_str_date DATETIME,
	kc_stop_date DATETIME,
	kc_all_cnt int,	
	a int,	
	b int,	
	datatype	varchar(2)			/* 月份 */
)
--到期回收率
DECLARE @tmp_deadline TABLE 
(	
	kc_comp_code	varchar(4),
    kc_prod_type	varchar(2),
	kc_stop_date DATETIME,
	kc_pay_amt int,	
	kc_expt_sum int,	
	datatype	varchar(2)			/* 月份 */
)
--逾3金額比
DECLARE @tmp_over3 TABLE 
(	
	kc_comp_code	varchar(4),
    kc_prod_type	varchar(2),
	kc_stop_date DATETIME,
	kc_expt_allsum int,	
	kc_bad_expt_allsum int,	
	kc_bad_pay_fee int,	
	datatype	varchar(2)			/* 月份 */
)


	DECLARE
	--str 月初 stop 月尾   0當月 1上月 2前月 ... 以此類推
	@wk_date_0_str DATETIME,
	@wk_date_1_str DATETIME,
	@wk_date_2_str DATETIME,
	@wk_date_0_stop DATETIME,
	@wk_date_1_stop DATETIME,
	@wk_date_2_stop DATETIME,

	@wk_date_6_str DATETIME,
	@wk_date_7_str DATETIME,
	@wk_date_8_str DATETIME,
	@wk_date_6_stop DATETIME,
	@wk_date_7_stop DATETIME,
	@wk_date_8_stop DATETIME,

	@wk_date_16_str DATETIME,
	@wk_date_17_str DATETIME,
	@wk_date_18_str DATETIME,
	@wk_date_16_stop DATETIME,
	@wk_date_17_stop DATETIME,
	@wk_date_18_stop DATETIME,

	@wk_date_3_str DATETIME,
	@wk_date_3_stop DATETIME,
	@wk_date_5_str DATETIME,
	@wk_date_5_stop DATETIME


	select @wk_date_0_str = @pm_pay_date + '-01'
	select @wk_date_0_stop = DATEADD(SECOND, -1, DATEADD(MONTH, 1, DATEADD(DAY, -DAY(@wk_date_0_str) + 1, @wk_date_0_str)));
	select @wk_date_1_str = DATEADD(MONTH, -1,@wk_date_0_str)
	select @wk_date_1_stop = DATEADD(SECOND, -1, DATEADD(MONTH, 1, DATEADD(DAY, -DAY(@wk_date_1_str) + 1, @wk_date_1_str)));
	select @wk_date_2_str = DATEADD(MONTH, -2,@wk_date_0_str)
	select @wk_date_2_stop = DATEADD(SECOND, -1, DATEADD(MONTH, 1, DATEADD(DAY, -DAY(@wk_date_2_str) + 1, @wk_date_2_str)));
	--------------
	select @wk_date_6_str = DATEADD(MONTH, -6,@wk_date_0_str)
	select @wk_date_6_stop = DATEADD(SECOND, -1, DATEADD(MONTH, 1, DATEADD(DAY, -DAY(@wk_date_6_str) + 1, @wk_date_6_str)));
	select @wk_date_7_str = DATEADD(MONTH, -7,@wk_date_0_str)
	select @wk_date_7_stop = DATEADD(SECOND, -1, DATEADD(MONTH, 1, DATEADD(DAY, -DAY(@wk_date_7_str) + 1, @wk_date_7_str)));
	select @wk_date_8_str = DATEADD(MONTH, -8,@wk_date_0_str)
	select @wk_date_8_stop = DATEADD(SECOND, -1, DATEADD(MONTH, 1, DATEADD(DAY, -DAY(@wk_date_8_str) + 1, @wk_date_8_str)));
	--------------
	select @wk_date_16_str = DATEADD(MONTH, -16,@wk_date_0_str)
	select @wk_date_16_stop = DATEADD(SECOND, -1, DATEADD(MONTH, 1, DATEADD(DAY, -DAY(@wk_date_16_str) + 1, @wk_date_16_str)));
	select @wk_date_17_str = DATEADD(MONTH, -17,@wk_date_0_str)
	select @wk_date_17_stop = DATEADD(SECOND, -1, DATEADD(MONTH, 1, DATEADD(DAY, -DAY(@wk_date_17_str) + 1, @wk_date_17_str)));
	select @wk_date_18_str = DATEADD(MONTH, -18,@wk_date_0_str)
	select @wk_date_18_stop = DATEADD(SECOND, -1, DATEADD(MONTH, 1, DATEADD(DAY, -DAY(@wk_date_18_str) + 1, @wk_date_18_str)));

	select @wk_date_3_str = DATEADD(MONTH, -3,@wk_date_0_str)
	select @wk_date_3_stop = DATEADD(SECOND, -1, DATEADD(MONTH, 1, DATEADD(DAY, -DAY(@wk_date_3_str) + 1, @wk_date_3_str)));
	select @wk_date_5_str = DATEADD(MONTH, -5,@wk_date_0_str)
	select @wk_date_5_stop = DATEADD(SECOND, -1, DATEADD(MONTH, 1, DATEADD(DAY, -DAY(@wk_date_5_str) + 1, @wk_date_5_str)));
	--CP核准
	INSERT INTO @tmp_cpapply 
	select kc_comp_code,kc_prod_type,@wk_date_0_str as kc_str_date,@wk_date_0_stop as kc_stop_date,COUNT(kc_cp_no) as total_cnt,SUM(case when kc_apply_stat = 'P' then 1 else 0 end) as apply_P_cnt ,'0' as datatype
	from kcsd.kc_cpdata where  kc_cp_date between @wk_date_0_str and @wk_date_0_stop
	group by kc_comp_code,kc_prod_type

	INSERT INTO @tmp_cpapply 
	select kc_comp_code,kc_prod_type,@wk_date_1_str as kc_str_date,@wk_date_1_stop  as kc_stop_date,COUNT(kc_cp_no) as total_cnt,SUM(case when kc_apply_stat = 'P' then 1 else 0 end) as apply_P_cnt ,'1' as datatype
	from kcsd.kc_cpdata where  kc_cp_date between @wk_date_1_str and @wk_date_1_stop
	group by kc_comp_code,kc_prod_type

	INSERT INTO @tmp_cpapply 
	select kc_comp_code,kc_prod_type,@wk_date_2_str as kc_str_date,@wk_date_2_stop  as kc_stop_date,COUNT(kc_cp_no) as total_cnt,SUM(case when kc_apply_stat = 'P' then 1 else 0 end) as apply_P_cnt ,'2' as datatype
	from kcsd.kc_cpdata where  kc_cp_date between @wk_date_2_str and @wk_date_2_stop
	group by kc_comp_code,kc_prod_type

	--利率(a/b),建檔數
	INSERT INTO @tmp_case 
	SELECT A.kc_comp_code,A.kc_prod_type,@wk_date_6_str as kc_str_date,@wk_date_1_stop as kc_stop_date,
	COUNT(A.kc_case_no) as wk_all_cnt,
	sum((((A.kc_loan_perd * A.kc_perd_fee)-(A.kc_give_amt + isnull(l.wk_insu_fee,0)))*12)) as a, sum((A.kc_loan_perd*(A.kc_give_amt+isnull(l.wk_insu_fee,0)))) as b  ,'0' as datatype
	FROM kcsd.kc_customerloan A 
	LEFT JOIN(select isnull(sum(kc_insu_fee),0) as wk_insu_fee , kc_case_no from kcsd.kc_insurance_list_insu GROUP BY kc_case_no)l on A.kc_case_no = l.kc_case_no
	WHERE kc_loan_stat Not In ('Y','Z') 
	AND A.kc_buy_date Between @wk_date_6_str And @wk_date_1_stop
	GROUP BY A.kc_comp_code,A.kc_prod_type

	INSERT INTO @tmp_case 
	SELECT A.kc_comp_code,A.kc_prod_type,@wk_date_7_str as kc_str_date,@wk_date_2_stop as kc_stop_date,
	COUNT(A.kc_case_no) as wk_all_cnt,
	sum((((A.kc_loan_perd * A.kc_perd_fee)-(A.kc_give_amt + isnull(l.wk_insu_fee,0)))*12)) as a, sum((A.kc_loan_perd*(A.kc_give_amt+isnull(l.wk_insu_fee,0)))) as b  ,'1' as datatype
	FROM kcsd.kc_customerloan A 
	LEFT JOIN(select isnull(sum(kc_insu_fee),0) as wk_insu_fee , kc_case_no from kcsd.kc_insurance_list_insu GROUP BY kc_case_no)l on A.kc_case_no = l.kc_case_no
	WHERE kc_loan_stat Not In ('Y','Z') 
	AND A.kc_buy_date Between @wk_date_7_str And @wk_date_2_stop
	GROUP BY A.kc_comp_code,A.kc_prod_type

	INSERT INTO @tmp_case 
	SELECT A.kc_comp_code,A.kc_prod_type,@wk_date_8_str as kc_str_date,@wk_date_3_stop as kc_stop_date,
	COUNT(A.kc_case_no) as wk_all_cnt,
	sum((((A.kc_loan_perd * A.kc_perd_fee)-(A.kc_give_amt + isnull(l.wk_insu_fee,0)))*12)) as a, sum((A.kc_loan_perd*(A.kc_give_amt+isnull(l.wk_insu_fee,0)))) as b  ,'2' as datatype
	FROM kcsd.kc_customerloan A 
	LEFT JOIN(select isnull(sum(kc_insu_fee),0) as wk_insu_fee , kc_case_no from kcsd.kc_insurance_list_insu GROUP BY kc_case_no)l on A.kc_case_no = l.kc_case_no
	WHERE kc_loan_stat Not In ('Y','Z') 
	AND A.kc_buy_date Between @wk_date_8_str And @wk_date_3_stop
	GROUP BY A.kc_comp_code,A.kc_prod_type
------------
	--到期回收率
	--此
	INSERT INTO @tmp_deadline 
	select kc_comp_code,kc_prod_type,@wk_date_1_stop as kc_stop_date, SUM(wk_pay_amt) wk_pay_amt,SUM(wk_expt_sum) wk_expt_sum,'0' as datatype from
	(
	SELECT l.kc_case_no,c.kc_prod_type,c.kc_comp_code, 
	Sum(isnull(kc_pay_fee,0)) - Sum(isnull(kc_intr_fee,0)) as wk_pay_amt, 0 AS wk_expt_sum
	FROM kcsd.kc_loanpayment l left join kcsd.kc_customerloan c on l.kc_case_no = c.kc_case_no
	WHERE kc_pay_date <= @wk_date_1_stop and kc_expt_date <= @wk_date_1_stop
	GROUP BY l.kc_case_no,c.kc_prod_type,c.kc_comp_code
	union 
	SELECT l.kc_case_no,c.kc_prod_type,c.kc_comp_code,0 AS wk_pay_amt, Sum(kc_expt_fee) AS wk_expt_sum
	FROM kcsd.kc_loanpayment l left join kcsd.kc_customerloan c on l.kc_case_no = c.kc_case_no
	WHERE kc_expt_date <= @wk_date_1_stop
	and kc_perd_no < 50
	GROUP BY l.kc_case_no,c.kc_prod_type,c.kc_comp_code
	) as A GROUP BY kc_comp_code,kc_prod_type
	--上
	INSERT INTO @tmp_deadline 
	select kc_comp_code,kc_prod_type,@wk_date_2_stop as kc_stop_date, SUM(wk_pay_amt) wk_pay_amt,SUM(wk_expt_sum) wk_expt_sum,'1' as datatype from
	(
	SELECT l.kc_case_no,c.kc_prod_type,c.kc_comp_code, 
	Sum(isnull(kc_pay_fee,0)) - Sum(isnull(kc_intr_fee,0)) as wk_pay_amt, 0 AS wk_expt_sum
	FROM kcsd.kc_loanpayment l left join kcsd.kc_customerloan c on l.kc_case_no = c.kc_case_no
	WHERE kc_pay_date <= @wk_date_2_stop and kc_expt_date <= @wk_date_2_stop
	GROUP BY l.kc_case_no,c.kc_prod_type,c.kc_comp_code
	union 
	SELECT l.kc_case_no,c.kc_prod_type,c.kc_comp_code,0 AS wk_pay_amt, Sum(kc_expt_fee) AS wk_expt_sum
	FROM kcsd.kc_loanpayment l left join kcsd.kc_customerloan c on l.kc_case_no = c.kc_case_no
	WHERE kc_expt_date <= @wk_date_2_stop
	and kc_perd_no < 50
	GROUP BY l.kc_case_no,c.kc_prod_type,c.kc_comp_code
	) as B GROUP BY kc_comp_code,kc_prod_type
	--前
	INSERT INTO @tmp_deadline 
	select kc_comp_code,kc_prod_type,@wk_date_3_stop as kc_stop_date, SUM(wk_pay_amt) wk_pay_amt,SUM(wk_expt_sum) wk_expt_sum,'2' as datatype from
	(
	SELECT l.kc_case_no,c.kc_prod_type,c.kc_comp_code, 
	Sum(isnull(kc_pay_fee,0)) - Sum(isnull(kc_intr_fee,0)) as wk_pay_amt, 0 AS wk_expt_sum 
	FROM kcsd.kc_loanpayment l left join kcsd.kc_customerloan c on l.kc_case_no = c.kc_case_no
	WHERE kc_pay_date <= @wk_date_3_stop and kc_expt_date <= @wk_date_3_stop
	GROUP BY l.kc_case_no,c.kc_prod_type,c.kc_comp_code
	union 
	SELECT l.kc_case_no,c.kc_prod_type,c.kc_comp_code,0 AS wk_pay_amt, Sum(kc_expt_fee) AS wk_expt_sum
	FROM kcsd.kc_loanpayment l left join kcsd.kc_customerloan c on l.kc_case_no = c.kc_case_no
	WHERE kc_expt_date <= @wk_date_3_stop
	and kc_perd_no < 50
	GROUP BY l.kc_case_no,c.kc_prod_type,c.kc_comp_code
	) as C GROUP BY kc_comp_code,kc_prod_type
------------
--逾3金額比
--此
INSERT INTO @tmp_over3 
select kc_comp_code,kc_prod_type,@wk_date_5_stop as kc_stop_date,sum(wk_expt_allsum) as wk_expt_allsum,
ISNULL(SUM(case when  kc_over_count >= 3 and kc_over_amt > 0 then wk_expt_allsum END),0) as wk_bad_expt_allsum,
ISNULL(SUM(case when  kc_over_count >= 3 and kc_over_amt > 0 then kc_pay_fee END),0) as wk_bad_pay_fee,'0' as datatype
from (
SELECT A.kc_comp_code,A.kc_case_no,A.kc_prod_type,g.kc_over_count,g.kc_over_amt,SUM(A.kc_perd_fee * A.kc_loan_perd) AS wk_expt_allsum,
(SELECT ISNULL(SUM(kc_pay_fee), 0) FROM kcsd.kc_loanpayment WHERE kc_case_no = A.kc_case_no and kc_pay_date <= @wk_date_5_stop) as kc_pay_fee 
FROM kcsd.kc_customerloan A 
LEFT JOIN (
SELECT kc_case_no,
ISNULL((SELECT	DATEDIFF(day,MIN(kc_expt_date),DATEADD(day,1,@wk_date_5_stop))/30 FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND (kc_pay_date >= DATEADD(day,1,@wk_date_5_stop) OR kc_pay_date IS NULL)),0) AS kc_over_count,
(SELECT ISNULL(SUM(kc_expt_fee), 0) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_expt_date < DATEADD(day, 1, @wk_date_5_stop ) AND kc_perd_no < 50)-(SELECT ISNULL(SUM(kc_pay_fee), 0) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date <DATEADD(day, 1, @wk_date_5_stop))  AS kc_over_amt
FROM kcsd.kc_customerloan c
) g ON A.kc_case_no = g.kc_case_no
GROUP BY A.kc_comp_code,A.kc_case_no,A.kc_prod_type,g.kc_over_count,g.kc_over_amt
) as x 
group by kc_comp_code,kc_prod_type

--上
INSERT INTO @tmp_over3
select kc_comp_code,kc_prod_type,@wk_date_6_stop as kc_stop_date,sum(wk_expt_allsum) as wk_expt_allsum,
ISNULL(SUM(case when  kc_over_count >= 3 and kc_over_amt > 0 then wk_expt_allsum END),0) as wk_bad_expt_allsum,
ISNULL(SUM(case when  kc_over_count >= 3 and kc_over_amt > 0 then kc_pay_fee END),0) as wk_bad_pay_fee,'1' as datatype
from (
SELECT A.kc_comp_code,A.kc_case_no,A.kc_prod_type,g.kc_over_count,g.kc_over_amt,SUM(A.kc_perd_fee * A.kc_loan_perd) AS wk_expt_allsum,
(SELECT ISNULL(SUM(kc_pay_fee), 0) FROM kcsd.kc_loanpayment WHERE kc_case_no = A.kc_case_no and kc_pay_date <= @wk_date_6_stop) as kc_pay_fee 
FROM kcsd.kc_customerloan A 
LEFT JOIN (
SELECT kc_case_no,
ISNULL((SELECT	DATEDIFF(day,MIN(kc_expt_date),DATEADD(day,1,@wk_date_6_stop))/30 FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND (kc_pay_date >= DATEADD(day,1,@wk_date_6_stop) OR kc_pay_date IS NULL)),0) AS kc_over_count,
(SELECT ISNULL(SUM(kc_expt_fee), 0) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_expt_date < DATEADD(day, 1, @wk_date_6_stop ) AND kc_perd_no < 50)-(SELECT ISNULL(SUM(kc_pay_fee), 0) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date <DATEADD(day, 1, @wk_date_6_stop))  AS kc_over_amt
FROM kcsd.kc_customerloan c
) g ON A.kc_case_no = g.kc_case_no
GROUP BY A.kc_comp_code,A.kc_case_no,A.kc_prod_type,g.kc_over_count,g.kc_over_amt
) as x 
group by kc_comp_code,kc_prod_type


--前
INSERT INTO @tmp_over3
select kc_comp_code,kc_prod_type,@wk_date_7_stop as kc_stop_date,sum(wk_expt_allsum) as wk_expt_allsum,
ISNULL(SUM(case when  kc_over_count >= 3 and kc_over_amt > 0 then wk_expt_allsum END),0) as wk_bad_expt_allsum,
ISNULL(SUM(case when  kc_over_count >= 3 and kc_over_amt > 0 then kc_pay_fee END),0) as wk_bad_pay_fee,'2' as datatype
from (
SELECT A.kc_comp_code,A.kc_case_no,A.kc_prod_type,g.kc_over_count,g.kc_over_amt,SUM(A.kc_perd_fee * A.kc_loan_perd) AS wk_expt_allsum,
(SELECT ISNULL(SUM(kc_pay_fee), 0) FROM kcsd.kc_loanpayment WHERE kc_case_no = A.kc_case_no and kc_pay_date <= @wk_date_7_stop) as kc_pay_fee 
FROM kcsd.kc_customerloan A 
LEFT JOIN (
SELECT kc_case_no,
ISNULL((SELECT	DATEDIFF(day,MIN(kc_expt_date),DATEADD(day,1,@wk_date_7_stop))/30 FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND (kc_pay_date >= DATEADD(day,1,@wk_date_7_stop) OR kc_pay_date IS NULL)),0) AS kc_over_count,
(SELECT ISNULL(SUM(kc_expt_fee), 0) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_expt_date < DATEADD(day, 1, @wk_date_7_stop ) AND kc_perd_no < 50)-(SELECT ISNULL(SUM(kc_pay_fee), 0) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date <DATEADD(day, 1, @wk_date_7_stop))  AS kc_over_amt
FROM kcsd.kc_customerloan c
) g ON A.kc_case_no = g.kc_case_no
GROUP BY A.kc_comp_code,A.kc_case_no,A.kc_prod_type,g.kc_over_count,g.kc_over_amt
) as x 
group by kc_comp_code,kc_prod_type



--select * from
--@tmp_cpapply
--select * from
--@tmp_case
--select * from
--@tmp_deadline
--select * from
--@tmp_over3

INSERT INTO kcsd.kc_indexB007

select @pm_pay_date as kc_data_date,car.kc_agent_code,car.kc_prod_type,'0' datatype,
A.total_cnt,A.apply_P_cnt,
B.kc_all_cnt,B.a,B.b,
C.kc_pay_amt,C.kc_expt_sum,
D.kc_expt_allsum,D.kc_bad_expt_allsum,D.kc_bad_pay_fee

from kcsd.kc_caragentbranchProd car
left join @tmp_cpapply A on car.kc_agent_code = A.kc_comp_code and car.kc_prod_type = A.kc_prod_type and A.datatype = '0'
left join @tmp_case B on car.kc_agent_code = B.kc_comp_code and car.kc_prod_type = B.kc_prod_type and B.datatype = '0'
left join @tmp_deadline C on car.kc_agent_code = C.kc_comp_code and car.kc_prod_type = C.kc_prod_type and C.datatype = '0'
left join @tmp_over3 D on car.kc_agent_code = D.kc_comp_code and car.kc_prod_type = D.kc_prod_type and D.datatype = '0'
where 
(A.kc_comp_code is not null or B.kc_comp_code is not null or C.kc_comp_code is not null or D.kc_comp_code is not null )

union

select @pm_pay_date as kc_data_date,car.kc_agent_code,car.kc_prod_type,'1' datatype,
A.total_cnt,A.apply_P_cnt,
B.kc_all_cnt,B.a,B.b,
C.kc_pay_amt,C.kc_expt_sum,
D.kc_expt_allsum,D.kc_bad_expt_allsum,D.kc_bad_pay_fee

from kcsd.kc_caragentbranchProd car
left join @tmp_cpapply A on car.kc_agent_code = A.kc_comp_code and car.kc_prod_type = A.kc_prod_type and A.datatype = '1'
left join @tmp_case B on car.kc_agent_code = B.kc_comp_code and car.kc_prod_type = B.kc_prod_type and B.datatype = '1'
left join @tmp_deadline C on car.kc_agent_code = C.kc_comp_code and car.kc_prod_type = C.kc_prod_type and C.datatype = '1'
left join @tmp_over3 D on car.kc_agent_code = D.kc_comp_code and car.kc_prod_type = D.kc_prod_type and D.datatype = '1'
where 
(A.kc_comp_code is not null or B.kc_comp_code is not null or C.kc_comp_code is not null or D.kc_comp_code is not null )

union

select @pm_pay_date as kc_data_date,car.kc_agent_code,car.kc_prod_type,'2' datatype,
A.total_cnt,A.apply_P_cnt,
B.kc_all_cnt,B.a,B.b,
C.kc_pay_amt,C.kc_expt_sum,
D.kc_expt_allsum,D.kc_bad_expt_allsum,D.kc_bad_pay_fee

from kcsd.kc_caragentbranchProd car
left join @tmp_cpapply A on car.kc_agent_code = A.kc_comp_code and car.kc_prod_type = A.kc_prod_type and A.datatype = '2'
left join @tmp_case B on car.kc_agent_code = B.kc_comp_code and car.kc_prod_type = B.kc_prod_type and B.datatype = '2'
left join @tmp_deadline C on car.kc_agent_code = C.kc_comp_code and car.kc_prod_type = C.kc_prod_type and C.datatype = '2'
left join @tmp_over3 D on car.kc_agent_code = D.kc_comp_code and car.kc_prod_type = D.kc_prod_type and D.datatype = '2'
where 
(A.kc_comp_code is not null or B.kc_comp_code is not null or C.kc_comp_code is not null or D.kc_comp_code is not null )