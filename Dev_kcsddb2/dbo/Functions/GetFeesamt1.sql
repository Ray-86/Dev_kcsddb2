CREATE FUNCTION [dbo].[GetFeesamt1] (@case_no VARCHAR(10))
returns int
as
begin
declare @result int
	select @result = (isnull(tt.kc_proc_fee,0) - isnull(op.kc_pay_fee,0)) FROM 
	(SELECT SUM(kc_proc_fee) AS 'kc_proc_fee' FROM kcsd.kc_trafficticket WHERE kc_case_no = @case_no) AS tt,
	(SELECT SUM(kc_pay_fee) AS 'kc_pay_fee' FROM kcsd.kc_otherpayment WHERE kc_case_no = @case_no AND kc_offset_type = '01') AS op
return @result
END
