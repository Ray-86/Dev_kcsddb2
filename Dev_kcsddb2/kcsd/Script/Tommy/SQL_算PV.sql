
DECLARE @wk_case_no varchar(10);
DECLARE @wk_expt_date datetime;
DECLARE @PV DECIMAL(10, 2);

DECLARE @Principal DECIMAL(10, 2); -- 分期金額
--DECLARE @InterestRate DECIMAL(10, 4) = (0.20 / 12); -- 月利率
DECLARE @Payment DECIMAL(10, 2) ; -- 月付款
DECLARE @Periods INT; -- 期數


-- 建立暫存表存放明細
CREATE TABLE #AmortizationSchedule (
    kc_case_no varchar(10),
	kc_expt_date datetime,
    Period INT,
    BeginningBalance int,
    Payment int,
    Interest int,
	BreakFee int,
    PrincipalPaid int,
    EndingBalance int
);

--select @Principal=kc_loan_fee,@Payment=kc_perd_fee,@Periods=kc_loan_perd   from kcsd.kc_customerloan where kc_case_no = '2028989'

DECLARE	cursor_case_no_LtoL	CURSOR
FOR	

select c.kc_case_no from kcsd.kc_customerloan c
--left join [kcsd].[kc_loanpayment] l on c.kc_case_no = l.kc_case_no
where kc_issu_code = '06' and kc_prod_type <> '04' --and kc_buy_date between '2024-01-01' and '2024-01-31'
and kc_idle_date is null and kc_idle_amt is null and kc_idle_type is null
and kc_case_no in (
select kc_case_no from kcsd.kc_loanpayment where kc_expt_date between '2024-01-01' and '2025-12-31' group by kc_case_no
)
--and kc_case_no = '2023436'

OPEN cursor_case_no_LtoL
FETCH NEXT FROM cursor_case_no_LtoL INTO @wk_case_no


WHILE (@@FETCH_STATUS = 0)
BEGIN

select @Principal=kc_loan_fee,@Payment=kc_perd_fee,@Periods=kc_loan_perd   from kcsd.kc_customerloan where kc_case_no = @wk_case_no

DECLARE @chk_kc_pv_amt2 INT; --先確認有沒有資料
select @chk_kc_pv_amt2 = kc_pv_amt2 from kcsd.kc_loanpayment where kc_case_no = @wk_case_no and kc_perd_no = 1

if(@chk_kc_pv_amt2 > 0)
begin
SET @PV = @chk_kc_pv_amt2
end
else
begin
SET @PV = @Payment * (1 - POWER(1 + (0.20 / 12), -@Periods)) / (0.20 / 12);
SET @PV = ROUND(@PV,0)  ;
end


DECLARE @BreakFeeALL INT = @PV-@Principal; -- 總手續費
DECLARE @BreakFee_ INT = @BreakFeeALL%@Periods; -- 手續費餘數
DECLARE @BreakFee INT = @BreakFeeALL/@Periods; -- 手續費

-- 初始化
DECLARE @Period INT = 1;
DECLARE @BeginningBalance INT = @PV;
DECLARE @Interest INT;
DECLARE @PrincipalPaid INT;
DECLARE @EndingBalance INT;

WHILE @Period <= @Periods
BEGIN

if (@Period = @Periods) begin select @BreakFee = @BreakFee + @BreakFee_ end

select @wk_expt_date = kc_expt_date from  [kcsd].[kc_loanpayment] where kc_case_no =@wk_case_no and kc_perd_no = @Period


    SET @Interest = ROUND(@BeginningBalance * 0.2 / 12,0) ;
    SET @PrincipalPaid = @Payment - @Interest  - @BreakFee;
    SET @EndingBalance = @BeginningBalance - @PrincipalPaid - @BreakFee;

    INSERT INTO #AmortizationSchedule
    VALUES (@wk_case_no,@wk_expt_date,@Period, @BeginningBalance, @Payment, @Interest,@BreakFee, @PrincipalPaid, @EndingBalance);

    SET @BeginningBalance = @EndingBalance;
    SET @Period = @Period + 1;
END;

	FETCH NEXT FROM cursor_case_no_LtoL INTO @wk_case_no
END
CLOSE cursor_case_no_LtoL
DEALLOCATE cursor_case_no_LtoL;



    SELECT 
        CONVERT(nvarchar(6), kc_expt_date, 112) AS DateType,
        SUM(Payment) AS Payment,          -- 實繳金額
        SUM(PrincipalPaid) AS PrincipalPaid, -- 還本數
        SUM(Interest) AS Interest,       -- 利息收入
        SUM(BreakFee) AS BreakFee,       -- 手續費收入
        SUM(Interest) + SUM(BreakFee) AS TotalFee -- 財務收入
    FROM #AmortizationSchedule where kc_expt_date between '2024-01-01' and '2025-12-31'
    GROUP BY CONVERT(nvarchar(6), kc_expt_date, 112)
	order by CONVERT(nvarchar(6), kc_expt_date, 112)



	--SELECT * FROM #AmortizationSchedule ;


-- 清理暫存表
DROP TABLE #AmortizationSchedule;

