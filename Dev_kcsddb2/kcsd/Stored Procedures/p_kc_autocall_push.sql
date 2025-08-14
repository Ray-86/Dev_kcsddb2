

CREATE  PROCEDURE [kcsd].[p_kc_autocall_push]
@pm_pusher_date	smalldatetime = NULL
AS

IF @pm_pusher_date IS NULL
BEGIN
	SELECT @pm_pusher_date = DATEADD(DAY, 0, DATEDIFF(DAY, 0, GETDATE()))
END

INSERT INTO kcsd.kc_autocall
	( kc_call_type, kc_call_date, kc_case_no, kc_mobile_no)
SELECT 'Push01', GETDATE(), A.kc_case_no, LTRIM(RTRIM(B.kc_mobil_no))
FROM kcsd.kc_pushassign A
	LEFT JOIN kcsd.kc_customerloan B on A.kc_case_no = B.kc_case_no
WHERE A.kc_strt_date = @pm_pusher_date AND A.kc_pusher_code like 'P%' 
AND B.kc_mobil_no IS NOT NULL AND ISNUMERIC(B.kc_mobil_no) = 1 AND LEN(B.kc_mobil_no) = 10

