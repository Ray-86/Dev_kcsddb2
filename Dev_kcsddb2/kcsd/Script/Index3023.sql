-- 報表 - 稅務類 : 預估每約分期營收表
DECLARE @wk_strt_date Date = '2025-08-01',   --應繳日期起始
                   @wk_stop_date Date = '2025-08-01' --應繳日期結束

DECLARE @Result TABLE 
( 
	--kc_prod_type nvarchar(20), --產品別
	rate float, --利率
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
DECLARE @rate float=0.20, @yMonth int=12 --利率0.2, 1年12個月
DECLARE @kc_case_no varchar(10), @kc_buy_date date
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
	WHERE kc_expt_date BETWEEN @wk_strt_date AND @wk_stop_date
	     AND kc_prod_type<>'04'

OPEN Cursor_Cal 
FETCH NEXT FROM Cursor_Cal INTO @kc_case_no
WHILE (@@FETCH_STATUS=0)
BEGIN
	SELECT @kc_buy_date=kc_buy_date, @kc_loan_fee=kc_loan_fee, @kc_perd_fee=kc_perd_fee, @kc_loan_perd=kc_loan_perd, @kc_pvpay_amt2=kc_pv_amt2
	FROM kcsd.kc_customerloan C
	LEFT JOIN kcsd.kc_loanpayment P 
				ON C.kc_case_no=P.kc_case_no 
			 AND P.kc_perd_no=1
	WHERE C.kc_case_no=@kc_case_no

	SET @CurPeriod=1 
	SET @rate=0.20
	IF @kc_pvpay_amt2 <=0  OR @kc_pvpay_amt2 IS NULL--確認是否有第一期資料, 若無則計算                                           --四捨五入到整數位
		SET @kc_pvpay_amt2= ROUND(@kc_perd_fee * (1 - POWER(1 + (@rate / @yMonth), - @kc_loan_perd)) / (@rate / @yMonth), 0); 
	--確認利率, 還本數需大於分期金額 
	WHILE @kc_pvpay_amt2<@kc_loan_fee
	BEGIN                                                      --2017-07-01前每次-0.05, 後則-0.01  參考分期系統DysCommon.getTargetRateFee(客編);
		SET @rate-=CASE WHEN @kc_buy_date>='2017-07-01' THEN 0.01 ELSE 0.05 END 
		SET @kc_pvpay_amt2= ROUND(@kc_perd_fee * (1 - POWER(1 + (@rate / @yMonth), - @kc_loan_perd)) / (@rate / @yMonth), 0); 
	END

	SET @kc_proc_all=@kc_pvpay_amt2-@kc_loan_fee --手續費=還本數-分期金額
	SET @pkc_proc_amt=@kc_proc_all/@kc_loan_perd 
	SET @kc_proc_last=@pkc_proc_amt+@kc_proc_all%@kc_loan_perd
	
	WHILE @CurPeriod <= @kc_loan_perd
	BEGIN     --末期手續費不同
		IF @CurPeriod=@kc_loan_perd 
			SET @pkc_proc_amt=@kc_proc_last

		SET @pkc_invo_amt2=ROUND(@kc_pvpay_amt2*@rate/@yMonth, 0)
		SET @pkc_pvpay_amt2=@kc_perd_fee-@pkc_invo_amt2-@pkc_proc_amt
		SET @kc_pvpay_amt2= @kc_pvpay_amt2-@pkc_pvpay_amt2-@pkc_proc_amt
		INSERT INTO @Result VALUES ( @rate, @kc_case_no, @CurPeriod, @kc_perd_fee, @pkc_pvpay_amt2, @pkc_invo_amt2, @pkc_proc_amt)

		SET @CurPeriod+=1;
	END
	FETCH NEXT FROM Cursor_Cal INTO @kc_case_no
END
CLOSE Cursor_Cal
DEALLOCATE Cursor_Cal;

SELECT *
FROM @Result R
INNER JOIN kcsd.kc_loanpayment P ON R.kc_perd_item=P.kc_perd_no AND R.kc_case_no=P.kc_case_no
INNER JOIN kcsd.kc_customerloan C ON  R.kc_case_no=C.kc_case_no
INNER JOIN [Zephyr.Sys].dbo.sys_code SC --產品別
				ON C.kc_prod_type=SC.[Value] AND SC.CodeType='ProductType' 
WHERE P.kc_expt_date BETWEEN @wk_strt_date AND @wk_stop_date
     AND kc_prod_type ='18'

SELECT kc_prod_type + ' ' + SC.[Text] '產品別', 
			   SUM(ISNULL(P.kc_expt_fee, R.kc_expt_fee))'預估月付款', 
			   SUM(ISNULL(P.kc_pvpay_amt2, R.kc_pvpay_amt2))'還本數', 
               SUM(ISNULL(P.kc_invo_amt2, R.kc_invo_amt2))'利息收入', 
			   SUM(ISNULL(P.kc_proc_amt2, R.kc_proc_amt2))'手續費收入', 
			   SUM(ISNULL(P.kc_invo_amt2, R.kc_invo_amt2) + ISNULL(P.kc_proc_amt2, R.kc_proc_amt2))'財務收入', 
			   SUM(ISNULL(P.kc_pay_fee,0))'已繳金額', 
			   1.0*SUM(ISNULL(P.kc_pay_fee,0))/SUM(ISNULL(P.kc_expt_fee, R.kc_expt_fee))'回收率'
FROM @Result R
INNER JOIN kcsd.kc_loanpayment P ON R.kc_perd_item=P.kc_perd_no AND R.kc_case_no=P.kc_case_no
INNER JOIN kcsd.kc_customerloan C ON  R.kc_case_no=C.kc_case_no
INNER JOIN [Zephyr.Sys].dbo.sys_code SC --產品別
				ON C.kc_prod_type=SC.[Value] AND SC.CodeType='ProductType' 
WHERE P.kc_expt_date BETWEEN @wk_strt_date AND @wk_stop_date
GROUP BY kc_prod_type + ' ' + SC.[Text]
--ORDER BY R.kc_case_no 
/*
SELECT kc_prod_type + ' ' + SC.[Text] '產品別', kc_expt_fee'預估月付款', kc_pvpay_amt2'還本數', 
               kc_invo_amt2'利息收入', kc_proc_amt2'手續費收入', kc_invo_amt2+kc_proc_amt2'財務收入', 
			   kc_pay_fee'已繳金額', '回收率'
FROM kcsd.kc_customerloan C
INNER JOIN kcsd.kc_loanpayment P --應繳日期
				ON C.kc_case_no=P.kc_case_no
INNER JOIN [Zephyr.Sys].dbo.sys_code SC --產品別
				ON C.kc_prod_type=SC.[Value] AND  SC.CodeType='ProductType' 
WHERE P.kc_expt_date BETWEEN @wk_strt_date AND @wk_stop_date
     AND kc_prod_type <> '04' --應收排除 04 原車買賣
--GROUP BY kc_prod_type

SELECT TOP 10 * FROM kcsd.kc_loanpayment WHERE kc_pay_date IS NULL ORDER BY kc_expt_date DESC
*/