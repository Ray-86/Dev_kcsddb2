-- 報表 - 稅務類 : 預估年度分期營收表
DECLARE @wk_year_no int = '2027',  --年度
				   @wk_issu_code varchar(2)='06' --公司別
DECLARE @Result TABLE 
( 
	--kc_prod_type nvarchar(20), --產品別
	rate decimal(3, 2), --利率
	kc_case_no varchar(7), --客編
	kc_perd_item int, --期數
    kc_expt_fee int, --預估月付款
    kc_pvpay_amt2 int, --還本數'
    kc_invo_amt2 int, --利息收入
    kc_proc_amt2 int --手續費收入
   -- kc_invo_amt2+kc_proc_amt2'財務收入', 
    --kc_pay_fee int --已繳金額
    --回收率'
)
DECLARE @rate decimal(3,2), @yMonth int=12 --利率, 1年12個月
DECLARE @kc_case_no varchar(10), @kc_buy_date date, @kc_prod_type varchar(2)
                  --分期金額             --月付款                   --期數                           --還本數
DECLARE @kc_loan_fee int, @kc_perd_fee int, @kc_loan_perd int, @kc_pvpay_amt2 int
                  --總手續費             --單期手續費              --末期手續費 
DECLARE @kc_proc_all int, @pkc_proc_amt int, @kc_proc_last int
                  --目前期數                    --每期利息                   --每期還本數
DECLARE @CurPeriod int , @pkc_invo_amt2 int, @pkc_pvpay_amt2 int



DECLARE Cursor_Cal CURSOR
FOR 
	SELECT DISTINCT C.kc_case_no
	FROM kcsd.kc_customerloan C 
	INNER JOIN kcsd.kc_loanpayment P ON C.kc_case_no=P.kc_case_no
	WHERE YEAR(kc_expt_date) = @wk_year_no
		 AND  (@wk_issu_code='' OR  kc_issu_code=@wk_issu_code )

OPEN Cursor_Cal 
FETCH NEXT FROM Cursor_Cal INTO @kc_case_no
WHILE (@@FETCH_STATUS=0)
BEGIN
	SELECT @kc_prod_type=kc_prod_type, @kc_buy_date=kc_buy_date, @kc_loan_fee=kc_loan_fee, @kc_perd_fee=kc_perd_fee, @kc_loan_perd=kc_loan_perd, @kc_pvpay_amt2=kc_pv_amt2
	FROM kcsd.kc_customerloan C
	LEFT JOIN kcsd.kc_loanpayment P 
				ON C.kc_case_no=P.kc_case_no 
			 AND P.kc_perd_no=1
	WHERE C.kc_case_no=@kc_case_no

	SET @CurPeriod=1 
	IF @kc_prod_type <> '04'
	BEGIN
		SET @rate=0.20
		IF @kc_pvpay_amt2 <=0  OR @kc_pvpay_amt2 IS NULL--確認是否有第一期資料, 若無則計算                                           --四捨五入到整數位
			SET @kc_pvpay_amt2= ROUND(@kc_perd_fee * (1 - POWER(1 + (@rate / @yMonth), - @kc_loan_perd)) / (@rate / @yMonth), 0); 
		--確認利率, 還本數需大於分期金額 
		WHILE @kc_pvpay_amt2<@kc_loan_fee
		BEGIN                                                      --2017-07-01前每次-0.05, 後則-0.01  參考分期系統DysCommon.getTargetRateFee(客編);
			SET @rate-=CASE WHEN @kc_buy_date>='2017-07-01' THEN 0.01 ELSE 0.05 END 
			SET @kc_pvpay_amt2= CASE WHEN @rate>0 THEN ROUND(@kc_perd_fee * (1 - POWER(1 + (@rate / @yMonth), - @kc_loan_perd)) / (@rate / @yMonth), 0) ELSE 0 END; 
			IF @rate=0.00
				BREAK;
		END
	END 
	ELSE 
		SELECT @rate=0.00, @kc_pvpay_amt2=0

	SET @kc_proc_all=CASE WHEN @rate>0 THEN @kc_pvpay_amt2-@kc_loan_fee ELSE 0 END --手續費=還本數-分期金額
	SET @pkc_proc_amt=@kc_proc_all/@kc_loan_perd 
	SET @kc_proc_last=@pkc_proc_amt+@kc_proc_all%@kc_loan_perd
	
	WHILE @CurPeriod <= @kc_loan_perd
	BEGIN     --末期手續費不同
		IF @CurPeriod=@kc_loan_perd 
			SET @pkc_proc_amt=@kc_proc_last

		SET @pkc_invo_amt2=CASE WHEN @kc_prod_type<>'04' THEN ROUND(@kc_pvpay_amt2*@rate/@yMonth, 0) ELSE 0 END
		SET @pkc_pvpay_amt2=CASE WHEN @kc_prod_type<>'04' THEN @kc_perd_fee-@pkc_invo_amt2-@pkc_proc_amt ELSE 0 END
		SET @kc_pvpay_amt2= @kc_pvpay_amt2-@pkc_pvpay_amt2-@pkc_proc_amt
		INSERT INTO @Result VALUES ( @rate, @kc_case_no, @CurPeriod, @kc_perd_fee, @pkc_pvpay_amt2, @pkc_invo_amt2, @pkc_proc_amt)

		SET @CurPeriod+=1;
	END
	FETCH NEXT FROM Cursor_Cal INTO @kc_case_no
END
CLOSE Cursor_Cal
DEALLOCATE Cursor_Cal;

/*
SELECT MONTH(kc_expt_date) '月',
			   SUM(CASE WHEN C.kc_prod_type='04' THEN R.kc_expt_fee ELSE 0 END)'預估月付款(買賣)', --04
			   SUM(CASE WHEN C.kc_prod_type<>'04' THEN R.kc_expt_fee ELSE 0 END)'預估月付款(應收)', --<>04
			   SUM(R.kc_expt_fee)'預估月付款小計', 
			   SUM(R.kc_pvpay_amt2)'還本數', 
               SUM(R.kc_invo_amt2)'利息收入', 
			   SUM(R.kc_proc_amt2)'手續費收入', 
			   SUM(R.kc_invo_amt2+R.kc_proc_amt2)*1.05'財務收入小計', 
			   SUM(R.kc_invo_amt2+R.kc_proc_amt2)'財務收入小計(未稅)', 
			   SUM(ISNULL(P.kc_pay_fee,0))'已繳金額', 
			   1.0*SUM(ISNULL(P.kc_pay_fee,0))/SUM(R.kc_expt_fee)'回收率'
FROM @Result R
INNER JOIN kcsd.kc_loanpayment P ON R.kc_perd_item=P.kc_perd_no AND R.kc_case_no=P.kc_case_no
INNER JOIN kcsd.kc_customerloan C ON  R.kc_case_no=C.kc_case_no
WHERE YEAR(kc_expt_date)=@wk_year_no
GROUP BY MONTH(kc_expt_date)
*/

SELECT @wk_year_no-1911'year_no', @wk_issu_code'kc_issu_code', Item, ISNULL([1], 0), ISNULL([2], 0), ISNULL([3], 0), ISNULL([4], 0), ISNULL([5], 0), ISNULL([6], 0), ISNULL([7], 0), ISNULL([8], 0), ISNULL([9], 0), ISNULL([10], 0), ISNULL([11], 0), ISNULL([12], 0), ISNULL([1], 0) + ISNULL([2], 0) + ISNULL([3], 0) + ISNULL([4], 0) + ISNULL([5], 0) + ISNULL([6], 0) + ISNULL([7], 0) + ISNULL([8], 0) + ISNULL([9], 0) + ISNULL([10], 0) + ISNULL([11], 0) + ISNULL([12], 0)'Total'
FROM (
    SELECT
	    1 AS order_no,
        MONTH(P.kc_expt_date) AS _month,
        '預估月付款(買賣)' AS Item,
        SUM(CASE WHEN C.kc_prod_type = '04' THEN R.kc_expt_fee ELSE 0 END) AS _fee
    FROM @Result R
    INNER JOIN kcsd.kc_loanpayment P ON R.kc_perd_item = P.kc_perd_no AND R.kc_case_no = P.kc_case_no
    INNER JOIN kcsd.kc_customerloan C ON R.kc_case_no = C.kc_case_no
    WHERE YEAR(P.kc_expt_date) = @wk_year_no
    GROUP BY MONTH(P.kc_expt_date), C.kc_prod_type
	UNION ALL   
    SELECT
	    2 AS order_no,
        MONTH(P.kc_expt_date) AS _month,
        '預估月付款(應收)' AS Item,
        SUM(CASE WHEN C.kc_prod_type<>'04' THEN R.kc_expt_fee ELSE 0 END) AS _fee
    FROM @Result R
    INNER JOIN kcsd.kc_loanpayment P ON R.kc_perd_item = P.kc_perd_no AND R.kc_case_no = P.kc_case_no
    INNER JOIN kcsd.kc_customerloan C ON R.kc_case_no = C.kc_case_no
    WHERE YEAR(P.kc_expt_date) = @wk_year_no
    GROUP BY MONTH(P.kc_expt_date), C.kc_prod_type
	UNION ALL   
    SELECT
	    3 AS order_no,
        MONTH(P.kc_expt_date) AS _month,
        '預估月付款小計' AS Item,
        SUM(R.kc_expt_fee) AS _fee
    FROM @Result R
    INNER JOIN kcsd.kc_loanpayment P ON R.kc_perd_item = P.kc_perd_no AND R.kc_case_no = P.kc_case_no
    INNER JOIN kcsd.kc_customerloan C ON R.kc_case_no = C.kc_case_no
    WHERE YEAR(P.kc_expt_date) = @wk_year_no
    GROUP BY MONTH(P.kc_expt_date), C.kc_prod_type	
	UNION ALL   
    SELECT
	    4 AS order_no,
        MONTH(P.kc_expt_date) AS _month,
        '還本數' AS Item,
        SUM(R.kc_pvpay_amt2) AS _fee
    FROM @Result R
    INNER JOIN kcsd.kc_loanpayment P ON R.kc_perd_item = P.kc_perd_no AND R.kc_case_no = P.kc_case_no
    INNER JOIN kcsd.kc_customerloan C ON R.kc_case_no = C.kc_case_no
    WHERE YEAR(P.kc_expt_date) = @wk_year_no
    GROUP BY MONTH(P.kc_expt_date), C.kc_prod_type
	UNION ALL   
    SELECT
	    5 AS order_no,
        MONTH(P.kc_expt_date) AS _month,
        '利息收入' AS Item,
        SUM(R.kc_invo_amt2) AS _fee
    FROM @Result R
    INNER JOIN kcsd.kc_loanpayment P ON R.kc_perd_item = P.kc_perd_no AND R.kc_case_no = P.kc_case_no
    INNER JOIN kcsd.kc_customerloan C ON R.kc_case_no = C.kc_case_no
    WHERE YEAR(P.kc_expt_date) = @wk_year_no
    GROUP BY MONTH(P.kc_expt_date), C.kc_prod_type	
	UNION ALL   
    SELECT
	    6 AS order_no,
        MONTH(P.kc_expt_date) AS _month,
        '手續費收入' AS Item,
        SUM(R.kc_proc_amt2) AS _fee
    FROM @Result R
    INNER JOIN kcsd.kc_loanpayment P ON R.kc_perd_item = P.kc_perd_no AND R.kc_case_no = P.kc_case_no
    INNER JOIN kcsd.kc_customerloan C ON R.kc_case_no = C.kc_case_no
    WHERE YEAR(P.kc_expt_date) = @wk_year_no
    GROUP BY MONTH(P.kc_expt_date), C.kc_prod_type
	UNION ALL   
    SELECT
	    7 AS order_no,
        MONTH(P.kc_expt_date) AS _month,
        '財務收入小計' AS Item,
        CONVERT(INT,ROUND(SUM(R.kc_invo_amt2+R.kc_proc_amt2)*1.05,0)) AS _fee
    FROM @Result R
    INNER JOIN kcsd.kc_loanpayment P ON R.kc_perd_item = P.kc_perd_no AND R.kc_case_no = P.kc_case_no
    INNER JOIN kcsd.kc_customerloan C ON R.kc_case_no = C.kc_case_no
    WHERE YEAR(P.kc_expt_date) = @wk_year_no
    GROUP BY MONTH(P.kc_expt_date), C.kc_prod_type
	UNION ALL   
    SELECT
	    8 AS order_no,
        MONTH(P.kc_expt_date) AS _month,
        '財務收入小計(未稅)' AS Item,
        SUM(R.kc_invo_amt2+R.kc_proc_amt2) AS _fee
    FROM @Result R
    INNER JOIN kcsd.kc_loanpayment P ON R.kc_perd_item = P.kc_perd_no AND R.kc_case_no = P.kc_case_no
    INNER JOIN kcsd.kc_customerloan C ON R.kc_case_no = C.kc_case_no
    WHERE YEAR(P.kc_expt_date) = @wk_year_no
    GROUP BY MONTH(P.kc_expt_date), C.kc_prod_type
	UNION ALL   
    SELECT
	    9 AS order_no,
        MONTH(P.kc_expt_date) AS _month,
        '已繳金額' AS Item,
        SUM(ISNULL(P.kc_pay_fee,0)) AS _fee
    FROM @Result R
    INNER JOIN kcsd.kc_loanpayment P ON R.kc_perd_item = P.kc_perd_no AND R.kc_case_no = P.kc_case_no
    INNER JOIN kcsd.kc_customerloan C ON R.kc_case_no = C.kc_case_no
    WHERE YEAR(P.kc_expt_date) = @wk_year_no
    GROUP BY MONTH(P.kc_expt_date), C.kc_prod_type
) AS SourceTable
PIVOT (
   SUM(_fee)FOR _month IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
) AS PivotTable
ORDER BY order_no;
