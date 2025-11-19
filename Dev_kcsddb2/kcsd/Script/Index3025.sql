DECLARE @YM TABLE ( Seq int, YM varchar(5))
DECLARE @Index int=0, @sYear int=YEAR(@wk_strt_date)-1911, @sMonth int=MONTH(@wk_strt_date)
WHILE @Index < DATEDIFF(MONTH, @wk_strt_date, @wk_stop_date)+1
BEGIN
INSERT INTO @YM VALUES ( @Index+1, CONCAT(CASE WHEN @sMonth+@Index<13 THEN @sYear ELSE @sYear+1 END, CASE WHEN @sMonth+@Index!=12 AND (@sMonth+@Index)%12<10 THEN '0' ELSE '' END, CASE WHEN @sMonth+@Index=12 THEN 12 ELSE (@sMonth+@Index)%12 END))
SET @Index+=1
END

DECLARE @PD TABLE ( Seq int, Isu nvarchar(20),PD nvarchar(20))
INSERT INTO @PD
SELECT MIN(Y.Seq), 
	CASE WHEN L.kc_issu_code IN ('01', '02', '03', '06') THEN SUBSTRING(kc_issu_desc, 1, 4) ELSE '東元騰' END AS '公司別', 
			  MIN(kc_prod_type + ' ' + SC.[Text])'產品別'
FROM kcsd.kc_customerloan L
INNER JOIN kcsd.kct_issuecompany I ON L.kc_issu_code = I.kc_issu_code
INNER JOIN [Zephyr.Sys].dbo.sys_code SC ON SC.CodeType = 'ProductType' AND L.kc_prod_type = SC.[Value]
INNER JOIN @YM Y ON CONCAT(YEAR(kc_buy_date)-1911, CASE WHEN MONTH(kc_buy_date)<10 THEN '0' ELSE '' END, MONTH(kc_buy_date))=Y.YM
WHERE L.kc_buy_date Between @wk_strt_date and @wk_stop_date 
	  AND kc_loan_stat NOT IN ('X', 'Y', 'Z')
	  AND ( 
					(((L.kc_issu_code IN ('01', '03'))OR (L.kc_issu_code = '06'AND kc_prod_type <> '04')) AND kc_regissu_type = '1' AND kc_prod_type <> '08') --勞務件
				   OR
				   (L.kc_issu_code IN ('02','05') AND (LEFT(L.kc_case_no,1) BETWEEN '0' AND '5' OR LEFT(L.kc_case_no,1) <> 'T' ) )
				)
GROUP BY CASE WHEN L.kc_issu_code IN ('01', '02', '03', '06') THEN SUBSTRING(kc_issu_desc, 1, 4) ELSE '東元騰' END

SELECT *
	FROM 
(
SELECT Y.Seq,
	P.Isu'顯示公司別',
				   SUBSTRING(kc_issu_desc, 1, 4)'公司別',
				   kc_buy_date'購買日',
				   kc_prod_type + ' ' + SC.[Text]'產品別',
				   kc_loan_fee'撥款金額',
				   kc_perd_fee * kc_loan_perd'應收分期款'
	FROM kcsd.kc_customerloan L
	INNER JOIN kcsd.kct_issuecompany I ON L.kc_issu_code = I.kc_issu_code
	INNER JOIN [Zephyr.Sys].dbo.sys_code SC ON SC.CodeType = 'ProductType' AND L.kc_prod_type = SC.[Value]
	INNER JOIN @YM Y ON CONCAT(YEAR(kc_buy_date)-1911, CASE WHEN MONTH(kc_buy_date)<10 THEN '0' ELSE '' END, MONTH(kc_buy_date))=Y.YM
	LEFT JOIN @PD P ON SUBSTRING(kc_issu_desc, 1, 4)=P.Isu AND  kc_prod_type + ' ' + SC.[Text]=P.PD
	WHERE kc_regissu_type = '1'
	  AND ((L.kc_issu_code IN ('01', '03'))OR (L.kc_issu_code = '06'AND kc_prod_type <> '04'))
	  AND kc_buy_date BETWEEN @wk_strt_date AND @wk_stop_date
	  AND kc_prod_type <> '08' --勞務件
	  AND kc_loan_stat NOT IN ('X', 'Y', 'Z')

	UNION ALL 

SELECT  Y.Seq, 
	CASE WHEN L.kc_issu_code='02' THEN '東元機車' ELSE '東元騰' END'顯示公司別', 
	CASE WHEN L.kc_issu_code='02' THEN '東元機車' ELSE '東元騰' END'公司別', 
				   kc_buy_date'購買日',
				   kc_prod_type + ' ' + SC.[Text]'產品別',
				   kc_give_amt'撥款金額',
				   kc_strt_fee + kc_perd_fee*kc_loan_perd'應收分期款'
	FROM kcsd.kc_customerloan L
	INNER JOIN kcsd.kct_issuecompany I ON L.kc_issu_code = I.kc_issu_code
	INNER JOIN [Zephyr.Sys].dbo.sys_code SC ON SC.CodeType = 'ProductType' AND L.kc_prod_type = SC.[Value]
	INNER JOIN @YM Y ON CONCAT(YEAR(kc_buy_date)-1911, CASE WHEN MONTH(kc_buy_date)<10 THEN '0' ELSE '' END, MONTH(kc_buy_date))=Y.YM
	WHERE 1=1--L.kc_buy_date Between @wk_strt_date and @wk_stop_date 
		 AND L.kc_issu_code IN ('02','05') 
		 AND L.kc_loan_stat Not In ('X','Y','Z')AND
		(LEFT(L.kc_case_no,1) BETWEEN '0' AND '5' OR LEFT(L.kc_case_no,1) <> 'T' )
) A
ORDER BY Seq, 顯示公司別, 公司別, 產品別