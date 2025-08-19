--結果集
DECLARE @Result TABLE  (
	kc_perd_item int, --期數
	kc_perd_fee int,  --月付款
	kc_pvpay_amt2 int, --還本數
	kc_invo_amt2 int, --利息
	kc_proc_amt2 int --手續費收入
)
DECLARE @rate float=0.20, @yMonth int=12 --利率0.2, 1年12個月
DECLARE @kc_case_no varchar(10)='2230303', @kc_buy_date date--='W107749'
                  --分期金額             --月付款                   --期數                           --還本數
DECLARE @kc_loan_fee int, @kc_perd_fee int, @kc_loan_perd int, @kc_pvpay_amt2 int
SELECT @kc_buy_date=kc_buy_date, @kc_loan_fee=kc_loan_fee, @kc_perd_fee=kc_perd_fee, @kc_loan_perd=kc_loan_perd, @kc_pvpay_amt2=kc_pv_amt2
FROM kcsd.kc_customerloan C
LEFT JOIN kcsd.kc_loanpayment P 
			ON C.kc_case_no=P.kc_case_no 
		 AND P.kc_perd_no=1
WHERE C.kc_case_no=@kc_case_no

IF @kc_pvpay_amt2<=0  --確認是否有第一期資料, 若無則計算                                           --四捨五入到整數位
	SET @kc_pvpay_amt2= ROUND(@kc_perd_fee * (1 - POWER(1 + (@rate / @yMonth), - @kc_loan_perd)) / (@rate / @yMonth), 0); 

--確認利率, 還本數需大於分期金額
WHILE @kc_pvpay_amt2<@kc_loan_fee
BEGIN
	IF @rate<=0
		SELECT @rate
	SET @rate-=CASE WHEN @kc_buy_date>='2017-07-01' THEN 0.01 ELSE 0.05 END 

	SET @kc_pvpay_amt2= ROUND(@kc_perd_fee * (1 - POWER(1 + (@rate / @yMonth), - @kc_loan_perd)) / (@rate / @yMonth), 0); 
END

SELECT @rate
                  --總手續費             --單期手續費              --末期手續費 
DECLARE @kc_proc_all int, @pkc_proc_amt int, @kc_proc_last int
SET @kc_proc_all=@kc_pvpay_amt2-@kc_loan_fee --手續費=還本數-分期金額

SET @pkc_proc_amt=@kc_proc_all/@kc_loan_perd 
SET @kc_proc_last=@pkc_proc_amt+@kc_proc_all%@kc_loan_perd

                  --目前期數                    --每期利息                   --每期還本數
DECLARE @CurPeriod int , @pkc_invo_amt2 int, @pkc_pvpay_amt2 int

SELECT @CurPeriod=1, @rate=0.20
WHILE @CurPeriod <= @kc_loan_perd
BEGIN     --末期手續費不同
	IF @CurPeriod=@kc_loan_perd 
		SET @pkc_proc_amt=@kc_proc_last

	SET @pkc_invo_amt2=ROUND(@kc_pvpay_amt2*@rate/@yMonth, 0)
	SET @pkc_pvpay_amt2=@kc_perd_fee-@pkc_invo_amt2-@pkc_proc_amt
	SET @kc_pvpay_amt2= @kc_pvpay_amt2-@pkc_pvpay_amt2-@pkc_proc_amt
	INSERT INTO @Result VALUES ( @CurPeriod, @kc_perd_fee, @pkc_pvpay_amt2, @pkc_invo_amt2, @pkc_proc_amt)

	SET @CurPeriod+=1;
END

SELECT * FROM @Result