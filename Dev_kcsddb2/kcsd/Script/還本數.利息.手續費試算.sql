--結果集
DECLARE @Result TABLE 
( 
	kc_perd_item int, --期數
	kc_perd_fee int,  --月付款
	kc_pvpay_amt2 int, --還本數
	kc_invo_amt2 int, --利息
	kc_proc_amt2 int --手續費收入
);

DECLARE @kc_case_no varchar(10)='T103835'
                  --分期金額             --月付款                   --期數                           --還本數
DECLARE @kc_loan_fee int, @kc_perd_fee int, @kc_loan_perd int, @kc_pvpay_amt2 int
SELECT @kc_loan_fee=kc_loan_fee, @kc_perd_fee=kc_perd_fee, @kc_loan_perd=kc_loan_perd, @First_pv=kc_pv_amt2
FROM kcsd.kc_customerloan C
LEFT JOIN kcsd.kc_loanpayment P 
			ON C.kc_case_no=P.kc_case_no 
		 AND P.kc_perd_no=1
WHERE C.kc_case_no=@kc_case_no

SELECT @kc_loan_fee, @kc_perd_fee, @kc_loan_perd, @First_pv

IF @kc_pvpay_amt2 IS NULL  --確認是否有第一期資料, 若無則計算                                           --四捨五入到整數位
	SET @kc_pvpay_amt2= ROUND(@kc_perd_fee * (1 - POWER(1 + (0.20 / 12), - @kc_loan_perd)) / (0.20 / 12), 0); 

                  --總手續費             --單期手續費              --末期手續費 
DECLARE @kc_proc_all int, @pkc_proc_amt int, @kc_proc_last int
SET @kc_proc_all=@kc_pvpay_amt2-@kc_loan_fee --手續費=還本數-分期金額
SET @pkc_proc_amt=@kc_proc_all/@kc_loan_perd 
SET @kc_proc_last=@pkc_proc_amt+@kc_proc_all%@kc_loan_perd

                  --目前期數                    --每期利息                
DECLARE @CurPeriod int = 1, @pInterest int, @PrincipalPaid int

SET @pInterest=

WHILE @CurPeriod <= @kc_loan_perd
BEGIN
	SELECT 1

	
END