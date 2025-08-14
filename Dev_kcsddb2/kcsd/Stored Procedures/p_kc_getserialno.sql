---- ==========================================================================================
-- 2013-06-03 將CP取號方式改為統一由伺服器給值 (避免日期錯誤)
-- ==========================================================================================
CREATE    PROCEDURE [kcsd].[p_kc_getserialno]
	@pm_sys_code varchar(10)='CP',
	@pm_ser_no int=0,
	@wk_host_no varchar(1)='0',
	@pm_cp_no varchar(10)='' OUTPUT
AS
DECLARE	@wk_today_date datetime

SELECT	@wk_today_date =  CONVERT(varchar(10), GETDATE(), 23)

IF	@pm_sys_code = 'CP'
BEGIN
	BEGIN TRANSACTION
		SELECT	@pm_ser_no = ISNULL(kc_ser_no, 0)
		FROM	kcsd.kc_serialno
		WHERE	kc_sys_code = 'CP'
		AND	kc_ser_date = @wk_today_date

		IF	@pm_ser_no = 0
			INSERT INTO kcsd.kc_serialno (kc_sys_code, kc_ser_date, kc_ser_no) VALUES ('CP', @wk_today_date, 1)
		ELSE 
			UPDATE kcsd.kc_serialno SET kc_ser_no = @pm_ser_no + 1 WHERE kc_sys_code = 'CP' and kc_ser_date=@wk_today_date

 		if (@@SERVERNAME='DYS01')  select @wk_host_no = '1'
		else if (@@SERVERNAME='DYAP01')  select @wk_host_no = '0'
		SELECT  @pm_cp_no = CONVERT(varchar(6), GETDATE(), 12) + @wk_host_no + REPLICATE('0',(3 - LEN(@pm_ser_no))) + CONVERT(varchar(4),@pm_ser_no)
		--print
		SELECT	@pm_sys_code AS kc_sys_code, @wk_today_date AS kc_ser_date, @pm_ser_no AS kc_ser_no, @pm_cp_no AS kc_cp_no
	COMMIT TRANSACTION
END
