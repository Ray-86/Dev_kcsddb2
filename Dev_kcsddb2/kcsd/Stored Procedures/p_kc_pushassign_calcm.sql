-- ==========================================================================================
-- 2024-01-01 開始有新條件
-- 2012-11-05 依指派日與當期應繳日判斷M0~MX
-- ==========================================================================================
--M0 = 4~30天
--M1 = 逾期31~60天
--M2 = 逾期61~90天
--M3 = 逾期91~120天
--MX = 逾期121天以上

CREATE      PROCEDURE [kcsd].[p_kc_pushassign_calcm]
	@pm_case_no varchar(20),
	@pm_delay_code varchar(4) OUTPUT
AS

DECLARE	

	@wk_expt_date datetime,
	@wk_stop_date datetime,
	@i int,
	@numrows int

	if LEN(@pm_case_no) > 10
	begin
	--會員件


		SELECT	@wk_expt_date = MIN(kc_expt_date)
		FROM	kcsd.kc_customerloan c
	 	left join (select kc_case_no, MIN(kc_expt_date) kc_expt_date from kcsd.kc_loanpayment where kc_expt_date <= GETDATE() and kc_pay_date is null group by kc_case_no) l on c.kc_case_no = l.kc_case_no
		WHERE	kc_loan_stat IN ('D','F')
		AND c.kc_prod_type = '14'
		AND kc_member_no = @pm_case_no
		AND NOT EXISTS
			(SELECT	'X' 
			FROM kcsd.kc_memberpushassign p
			WHERE	p.kc_member_no = c.kc_member_no
			AND	p.kc_stop_date IS NULL)

	end
	else
	begin
		--一般件
		SELECT @wk_expt_date = min(A1.kc_expt_date) FROM (
		select * from kcsd.KC_LOANPAYMENT L2 
		WHERE L2.kc_case_no = @pm_case_no
		AND  L2.kc_pay_date IS NULL 
		AND  (L2.kc_pay_fee =0 OR L2.kc_pay_fee IS NULL)
		AND  kc_expt_date < GETDATE()
		) AS A1
    end
SET @i = 0
SET @numrows = 9
  WHILE (@i < @numrows)
  BEGIN

  select @wk_stop_date =  dateadd(ms,-3,DATEADD( DD,1,DATEADD(M,@i,@wk_expt_date))) 

IF @wk_stop_date  < GETDATE() 
BEGIN
select @pm_delay_code = 'M' + CONVERT( VARCHAR(1) , case when @i >= 3 then 3 else @i end )
  SET @i = @i + 1
END
ELSE
BEGIN
  SET @i = 9
END
  END

  select @pm_delay_code as kc_delay_code




