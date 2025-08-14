CREATE PROCEDURE [kcsd].[p_kc_dailybackup(停用)] @Name VARCHAR(10)
AS

DECLARE @theDay VARCHAR(10)    --取得日期備份  
DECLARE @DBName VARCHAR(100)
DECLARE @ZIPName VARCHAR(100)
DECLARE @no AS VARCHAR(10)
DECLARE @begin DATETIME
DECLARE @end DATETIME
DECLARE @days INT
DECLARE @DELName VARCHAR(30)

--set @Name = 'dy2'
set @theDay=CONVERT(VARCHAR(10), GETDATE(), 112)
set @DBName = 'F:\SQL2000\MSSQL\BACKUP\' + @Name + '_' +@theDay + '.bak'    --資料庫備份檔名  
set @ZIPName = 'Z:\'+ @Name +'_' +@theDay + '.zip'

--刪除舊資料
set @begin = DATEADD(mm, DATEDIFF(mm,0,dateadd(mm,-1,getdate())), 0) --上個月第一天
set @end = CONVERT(VARCHAR(10),DATEADD(wk,DATEDIFF(wk,0,DATEADD(mm, DATEDIFF(mm,0,getdate()), 0)),-2),112) --本月的第一天的前一個禮拜
set @days = DATEDIFF(dd,@begin,@end)

DECLARE c1 CURSOR FOR
select DATEADD(dd,number,@begin) from master.dbo.spt_values where type='P' AND number<=@days;
OPEN c1
FETCH NEXT FROM c1 INTO @no
WHILE @@FETCH_STATUS = 0
begin
	SET @DELName = 'Z:\'+@Name+'_' + CONVERT(VARCHAR(10), @begin, 112) + '.zip'
	SELECT @begin = dateadd(dd,+1,@begin)
	exec('master..xp_cmdshell ''del '+@DELName+' '' ')
	--PRINT @DELName

--進行DB備份
IF @Name = 'dy1' 
	BACKUP DATABASE kcsddb  TO DISK=@DBName WITH  INIT	
ELSE IF @Name = 'dy2' 
	BACKUP DATABASE kcsddb2  TO DISK=@DBName WITH  INIT
ELSE IF @Name = 'dy3' 
	BACKUP DATABASE kcsddb3  TO DISK=@DBName WITH  INIT
ELSE IF @Name = 'invo' 
	BACKUP DATABASE invodb  TO DISK=@DBName WITH  INIT

--2013/4/10 測試將路徑改為 \\dys01a\DYSYS\資訊\DBbackup
exec master..xp_cmdshell 'net use z: \\dys01a\DYSYS\資訊\DBbackup "neteater" /user:dys01a\administrator'
--exec master..xp_cmdshell 'net use z: \\dyap01\DBbackup "neteater" /user:dyap01\administrator'

FETCH NEXT FROM c1  INTO @no
end
CLOSE c1
DEALLOCATE c1

--壓縮移動
exec('master..xp_cmdshell ''C:\Progra~1\7-Zip\7z.exe a -tzip ' + @ZIPName + ' ' +@DBName +' '' ')
--exec('master..xp_cmdshell ''del '+@DBName+' '' ')
exec('master..xp_cmdshell ''del *.bak'' ')
exec master..xp_cmdshell 'net use z: /delete'
