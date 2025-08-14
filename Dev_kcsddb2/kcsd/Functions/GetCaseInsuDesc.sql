
CREATE FUNCTION [kcsd].[GetCaseInsuDesc] (@CaseNo VARCHAR(10))
RETURNS VARCHAR(MAX)
AS
BEGIN
DECLARE @result NVARCHAR(50)

SELECT @result = Owners
FROM (
	SELECT DISTINCT 
		STUFF((
			SELECT '/' + kct_insucategory.kc_cate_desc
			FROM kcsd.kc_insurance_list
			LEFT JOIN kcsd.kct_insucategory ON kc_insurance_list.kc_insu_cate = kct_insucategory.kc_insu_cate
			WHERE kc_insurance_list.kc_case_no = Temp.kc_case_no AND kc_insurance_list.kc_case_no = @CaseNo
			FOR XML PATH('')
		), 1, 1, '') AS Owners
	FROM kcsd.kc_insurance_list Temp
	WHERE Temp.kc_case_no = @CaseNo
	) AS X

RETURN @result
END
