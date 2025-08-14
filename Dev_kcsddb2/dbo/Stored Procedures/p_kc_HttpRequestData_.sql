


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE p_kc_HttpRequestData_  @wk_url varchar(255),@status varchar(255) out,@returnText varchar(255) out

AS
begin

declare @object int,
@errSrc int

exec @status = sp_OACreate 'Msxml2.ServerXMLHTTP3.0',@object OUT
IF @status <> 0
begin
EXEC sp_OAGetErrorInfo @object,@errSrc OUT,@returnText OUT
RETURN
END

exec @status = SP_oAmethod @object,'setRequestHeader','Content-Type','application/x-www-form-urlencoded'

exec @status = SP_oAmethod @object,'send',null

IF @status <> 0
begin
EXEC sp_OAGetErrorInfo @object,@errSrc OUT,@returnText OUT
RETURN
END

exec @status = sp_OAGetProperty @object,'responseText',@returnText OUT

IF @status <> 0
begin
EXEC sp_OAGetErrorInfo @object,@errSrc OUT,@returnText OUT
RETURN
END

END
