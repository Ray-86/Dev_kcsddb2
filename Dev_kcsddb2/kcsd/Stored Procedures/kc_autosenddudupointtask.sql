-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [kcsd].[kc_autosenddudupointtask]  @pm_run_code varchar(10)=NULL, @pm_send_date datetime=NULL

AS
BEGIN
		--已下是自動發送
		select @pm_send_date = isnull(@pm_send_date , GETDATE())
		DECLARE @wk_list_no VARCHAR(10) ;
		DECLARE @wk_memberno_list NVARCHAR(MAX);
		DECLARE @sql_A NVARCHAR(MAX) = N'
		select kc_target_ID from kcsd.kc_dudupointtasktarget_detail  WHERE kc_target_ID in ';
		DECLARE @sql_B NVARCHAR(MAX) = N' group by kc_target_ID ';
		DECLARE @where_sql NVARCHAR(MAX) = N'';
		DECLARE @conditions  NVARCHAR(MAX) = N'';
		DECLARE @DuDuPointTaskMembers  NVARCHAR(MAX) = N'';		

		DECLARE task_cursor CURSOR FOR

		select kc_list_no,kc_memberno_list from kcsd.kc_dudupointsend
		where kc_list_type = 'B'
		and kc_list_stat = 'B'
		and kc_sendat_type = 'A'
		and @pm_send_date >= kc_taskstrt_date
		union 
		select kc_list_no,kc_memberno_list from kcsd.kc_dudupointsend
		where kc_list_type = 'B'
		and kc_list_stat = 'B'
		and kc_sendat_type = 'B'
		and @pm_send_date >= kc_sendat_date
		and @pm_send_date >= kc_taskstrt_date

		OPEN task_cursor;
		FETCH NEXT FROM task_cursor INTO @wk_list_no,@wk_memberno_list;

		WHILE @@FETCH_STATUS = 0
		BEGIN
		 DECLARE @sql NVARCHAR(MAX) = N'';
    
		-- 動態組 WHERE 子句
		SELECT @where_sql = '(' + @wk_memberno_list + ')'

		-- 組完整查詢
		SET @sql = @sql_A + @where_sql + @sql_B;

		-- 輸出或執行
		--PRINT @sql;

		--取得有資格的會員
		EXECUTE [kcsd].[p_kc_GetDuDuPointTaskMembers]	@sql,@wk_list_no,@DuDuPointTaskMembers OUTPUT
		--select @DuDuPointTaskMembers

		--執行發送，並且保存結果
		EXECUTE [kcsd].[p_kc_DuDuPointSend]	@DuDuPointTaskMembers,@wk_list_no,@pm_run_code


			FETCH NEXT FROM task_cursor INTO @wk_list_no,@wk_memberno_list;
		END
		CLOSE task_cursor;
		DEALLOCATE task_cursor;



		--已下是手動發送

		
		DECLARE task_cursor CURSOR FOR

		select kc_list_no from kcsd.kc_dudupointsend where kc_list_type = 'A' and kc_list_stat = 'B' and kc_sendat_type = 'B' 
		and FORMAT(kc_sendat_date, 'yyyy-MM-dd') =  FORMAT(@pm_send_date, 'yyyy-MM-dd')

		OPEN task_cursor;
		FETCH NEXT FROM task_cursor INTO @wk_list_no;

		WHILE @@FETCH_STATUS = 0
		BEGIN

		--執行發送，並且保存結果
		EXECUTE [kcsd].[p_kc_DuDuPointSend_A]	@wk_list_no,@pm_run_code


			FETCH NEXT FROM task_cursor INTO @wk_list_no;
		END
		CLOSE task_cursor;
		DEALLOCATE task_cursor;


		--中繼資料表
		select * from kcsd.fake_dudupointsend_detail
		DELETE FROM kcsd.fake_dudupointsend_detail


END
