-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [kcsd].[p_kc_DuDuPointSend_A] @pm_list_no varchar(10)=NULL, @pm_run_code varchar(10)=NULL
AS
BEGIN

DECLARE @user_id VARCHAR(20);--會員ID
DECLARE @dudupoint int;--預發送DU幣
DECLARE @LastDayOfYear datetime;--今年最後一天

select @dudupoint = kc_dudupoint_fee ,@LastDayOfYear =  FORMAT(EOMONTH(DATEFROMPARTS(YEAR(GETDATE()), 12, 1)), 'yyyy-MM-dd')
from kcsd.kc_dudupointsend where kc_list_no = @pm_list_no

--假的測試用資料表
CREATE TABLE #tmp_dudupointsend_detail
(
kc_list_no  varchar(10),
kc_member_no varchar(15),
kc_dudupoint_fee int,
kc_expiration_date datetime,
IsEnable bit
)


-- Step 1: 將拆分後的 user 存到暫存表
SELECT value AS user_id
INTO #tmp_userlist
FROM kcsd.kc_dudupointsend
CROSS APPLY STRING_SPLIT(kc_memberno_list, ',')
where kc_list_no = @pm_list_no;

-- Step 2: 建立迴圈處理（WHILE 或 CURSOR 皆可）


DECLARE user_cursor CURSOR FOR
    SELECT user_id FROM #tmp_userlist;

OPEN user_cursor;
FETCH NEXT FROM user_cursor INTO @user_id;

WHILE @@FETCH_STATUS = 0
BEGIN

IF @pm_run_code = 'EXEC'
	BEGIN

	--新增一筆
	INSERT INTO kc_dudupointsend_detail (kc_list_no,kc_member_no,kc_dudupoint_fee,kc_expiration_date,IsEnable,kc_dudupoint_stat)
	VALUES (@pm_list_no,@user_id,@dudupoint,@LastDayOfYear,0,'A');

	--測試用
	INSERT INTO #tmp_dudupointsend_detail (kc_list_no, kc_member_no, kc_dudupoint_fee, kc_expiration_date, IsEnable)
		VALUES (@pm_list_no, @user_id, @dudupoint,@LastDayOfYear,0);

	END
ELSE
	BEGIN

	--測試用
	INSERT INTO #tmp_dudupointsend_detail (kc_list_no, kc_member_no, kc_dudupoint_fee, kc_expiration_date, IsEnable)
		VALUES (@pm_list_no, @user_id, @dudupoint,@LastDayOfYear,0);

	END

    -- 下筆
    FETCH NEXT FROM user_cursor INTO @user_id;
END

CLOSE user_cursor;
DEALLOCATE user_cursor;
DROP TABLE #tmp_userlist;



insert into fake_dudupointsend_detail
select * from #tmp_dudupointsend_detail

DROP TABLE #tmp_dudupointsend_detail


IF @pm_run_code = 'EXEC'
	BEGIN
	--發完幣改為C已結束
	UPDATE kcsd.kc_dudupointsend  SET kc_list_stat = 'C' where kc_list_no = @pm_list_no
	END

END
