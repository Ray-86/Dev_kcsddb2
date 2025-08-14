CREATE FUNCTION [dbo].[GetFeesamt2] (@case_no VARCHAR(10))
returns int
as
begin
declare @result int
	select @result = (isnull(tt.kc_tick_amt,0) - isnull(op.kc_pay_fee,0)) FROM 
	(SELECT SUM(kc_tick_amt) AS 'kc_tick_amt' FROM kcsd.kc_trafficticket WHERE (kc_pay_date is NOT NULL) AND kc_pay_type IN ('02','03') AND kc_case_no = @case_no) AS tt,
	(SELECT SUM(kc_pay_fee) AS 'kc_pay_fee' FROM kcsd.kc_otherpayment WHERE kc_case_no = @case_no AND kc_offset_type = '02') AS op
return @result
END
