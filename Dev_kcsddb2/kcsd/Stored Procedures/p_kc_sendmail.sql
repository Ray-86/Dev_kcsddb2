CREATE PROCEDURE [kcsd].[p_kc_sendmail]
	@To varchar(100),
	@Bcc varchar(500),
	@Subject varchar(400)=' ',
	@Body varchar(4000) =' '
AS
	
DECLARE @smtpserver varchar(50), --SMTP服務器地址
	@smtpusername varchar(50), --SMTP服務器用戶名
	@smtpuserpassWord varchar(50), --SMTP服務器密碼
	@object int, 
	@hr int

SET @smtpserver = 'mail.mydy.com.tw'
SET @smtpusername = 'automail@mydy.com.tw'
SET @smtpuserpassword = 'auto1220'
 
EXEC @hr = sp_OACreate 'CDO.Message', @object OUT 
EXEC @hr = sp_OASetProperty @object, 'Configuration.fields("http://schemas.microsoft.com/cdo/configuration/sendusing").Value','2' 
EXEC @hr = sp_OASetProperty @object, 'Configuration.fields("http://schemas.microsoft.com/cdo/configuration/smtpserver").Value', @smtpserver
EXEC @hr = sp_OASetProperty @object, 'Configuration.fields("http://schemas.microsoft.com/cdo/configuration/smtpserverport").Value','25' 
--下面三條語句是smtp驗證，如果服務器需要驗證，則必須要這三句，你需要修改用戶名和密碼
EXEC @hr = sp_OASetProperty @object, 'Configuration.fields("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate").Value','1' 
EXEC @hr = sp_OASetProperty @object, 'Configuration.fields("http://schemas.microsoft.com/cdo/configuration/sendusername").Value',@smtpusername
EXEC @hr = sp_OASetProperty @object, 'Configuration.fields("http://schemas.microsoft.com/cdo/configuration/sendpassword").Value',@smtpuserpassword
EXEC @hr = sp_OAMethod @object, 'Configuration.Fields.Update', null
EXEC @hr = sp_OASetProperty @object, 'To', @To
EXEC @hr = sp_OASetProperty @object, 'Bcc', @Bcc
EXEC @hr = sp_OASetProperty @object, 'From', @smtpusername
EXEC @hr = sp_OASetProperty @object, 'Subject', @Subject
EXEC @hr = sp_OASetProperty @object, 'TextBody', @Body
--EXEC @hr = sp_OASetProperty @object, 'HTMLBody', @Body 
EXEC @hr = sp_OASetProperty @object, 'HTMLBodyPart.Charset', 'utf-8'
EXEC @hr = sp_OAMethod @object, 'Send', NULL
--判斷出錯
IF @hr <> 0
BEGIN
EXEC sp_OAGetErrorInfo @object
print 'failed'
return @object
END

PRINT 'success'
EXEC @hr = sp_OADestroy @object
