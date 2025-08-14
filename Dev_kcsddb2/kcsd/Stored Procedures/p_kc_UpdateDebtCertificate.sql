-- ==========================================================================================
-- 2018
-- ==========================================================================================

CREATE PROCEDURE [kcsd].[p_kc_UpdateDebtCertificate] @pm_strt_date DATETIME, @pm_stop_date DATETIME,@pm_issu_code varchar(2) = NULL
AS
DECLARE @wk_case_no VARCHAR(10)

--清除資料
delete kcsd.kc_debtcertificate

EXEC sp_configure 'show advanced options',1   
RECONFIGURE WITH OVERRIDE    
EXEC sp_configure 'xp_cmdshell',1   
RECONFIGURE WITH OVERRIDE

--更新資料
DECLARE	cursor1	CURSOR
FOR	
	SELECT c.kc_case_no
	FROM kcsd.kc_customerloan c
	WHERE c.kc_case_no Not Like '9%' And
		kc_issu_code = @pm_issu_code AND
		kc_loan_stat Not In ('C','E','X','Y','Z') AND
		kc_idle_date is null AND
		EXISTS (SELECT 'x' FROM kcsd.kc_lawstatus WHERE kc_case_no=c.kc_case_no and kc_law_fmt In ('XA','C6') AND kc_doc_date Between @pm_strt_date AND @pm_stop_date)
	ORDER BY c.kc_case_no
OPEN cursor1
FETCH NEXT FROM cursor1 INTO @wk_case_no

WHILE (@@FETCH_STATUS = 0)
BEGIN
	DECLARE @Folder nvarchar(150)
	SET @Folder = '\\10.2.8.4\SCAN2\' + left(@wk_case_no,2) + '\' + @wk_case_no + '\'

	SET NOCOUNT ON  
	DECLARE @SQL NVARCHAR(MAX),@Return INT=0  
	IF OBJECT_ID('tempdb.dbo.#TEMP') IS NOT NULL DROP TABLE #TEMP
	CREATE TABLE #TEMP (RecNo INT IDENTITY,OUTPUT NVARCHAR(100))  
  

	SET @SQL=N'
            INSERT INTO #TEMP(OUTPUT)  
            EXEC xp_cmdshell ''dir ' + @Folder + '*.*'';  
            '
	--PRINT @SQL  
	EXEC(@SQL)
	
	INSERT kcsd.kc_debtcertificate(kc_case_no,subdirectory,kc_updt_date)
	SELECT @wk_case_no,RIGHT(OUTPUT,CHARINDEX(' ',REVERSE(OUTPUT))-1),GETDATE()
	FROM #TEMP WHERE OUTPUT LIKE '%.jpg'

	FETCH NEXT FROM cursor1 INTO @wk_case_no
END
CLOSE cursor1
DEALLOCATE cursor1;

EXEC sp_configure 'xp_cmdshell', 0  
RECONFIGURE WITH OVERRIDE  
EXEC sys.sp_configure N'show advanced options', N'0' 
RECONFIGURE WITH OVERRIDE  
