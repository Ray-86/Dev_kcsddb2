-- ==========================================================================================
-- 09/22/07 KC: 抓C2 後3個月內 未C4 
-- ==========================================================================================
CREATE    PROCEDURE [kcsd].[p_kc_rpt_lawc2c4(停用)]	@pm_strt_date DATETIME=NULL
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_law_date	datetime,
	@wk_law_date2	datetime,

	@wk_cust_name	varchar(40),	-- report only
	@wk_doc_no	varchar(40),	-- report only
	@wk_doc_type	varchar(40)	-- report only

IF	@pm_strt_date IS NULL
	SELECT	@pm_strt_date = '1/1/1990'

CREATE TABLE #tmp_lawc2c4
(kc_case_no	varchar(10),
kc_law_date	datetime,

-- report only columns
kc_cust_name	varchar(40),
kc_doc_no	varchar(40),
kc_doc_type	varchar(40)
)

SELECT	@wk_case_no=NULL, @wk_law_date=NULL

DECLARE	cursor_rpt_lawc2c4	CURSOR READ_ONLY
FOR	SELECT	w.kc_case_no, MAX(w.kc_law_date)
--FOR	SELECT	w.kc_case_no
	FROM	kcsd.kc_lawstatus w, kc_customerloan c
	WHERE	c.kc_case_no = w.kc_case_no
	AND	c.kc_pusher_code IS NOT NULL
	AND	w.kc_law_code = 'C'
	AND	w.kc_law_fmt = 'C2'
	AND	w.kc_law_date >= @pm_strt_date
	GROUP BY w.kc_case_no

OPEN cursor_rpt_lawc2c4
FETCH NEXT FROM cursor_rpt_lawc2c4 INTO @wk_case_no, @wk_law_date
--FETCH NEXT FROM cursor_rpt_lawc2c4 INTO @wk_case_no


WHILE (@@FETCH_STATUS = 0)
BEGIN
/*
	SELECT	@wk_law_date = MAX(kc_law_date)
	FROM	kcsd.kc_lawstatus
	WHERE	kc_case_no = @wk_case_no
	AND	kc_law_code = 'C'
	AND	kc_law_fmt = 'C2'
*/

	SELECT	@wk_law_date2 = DATEADD(month, 3, @wk_law_date),
		@wk_cust_name=NULL, @wk_doc_no=NULL, @wk_doc_type=NULL

	-- get report columns
	SELECT	@wk_cust_name = kc_cust_name
	FROM	kcsd.kc_customerloan
	WHERE	kc_case_no = @wk_case_no

	SELECT	@wk_doc_no = kc_doc_no, @wk_doc_type = kc_doc_type
	FROM	kcsd.kc_lawstatus
	WHERE	kc_case_no = @wk_case_no
	AND	kc_law_code = 'C'
	AND	kc_law_fmt = 'C2'

	IF	@wk_law_date2 < GETDATE()		-- C2到今天未滿3月, skip it
	AND	NOT EXISTS
		(SELECT	kc_case_no
		FROM	kcsd.kc_lawstatus
		WHERE	kc_case_no = @wk_case_no
		AND	kc_law_code = 'C'
		AND	kc_law_fmt = 'C4'
		AND	kc_law_date >= @wk_law_date)
	INSERT	#tmp_lawc2c4
		(kc_case_no, kc_law_date,
		kc_cust_name, kc_doc_no, kc_doc_type)
	VALUES	(@wk_case_no, @wk_law_date,
		@wk_cust_name, @wk_doc_no, @wk_doc_type)

	FETCH NEXT FROM cursor_rpt_lawc2c4 INTO @wk_case_no, @wk_law_date
--	FETCH NEXT FROM cursor_rpt_lawc2c4 INTO @wk_case_no
END

DEALLOCATE	cursor_rpt_lawc2c4

SELECT	*
FROM	#tmp_lawc2c4

DROP TABLE #tmp_lawc2c4
