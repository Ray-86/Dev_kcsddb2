-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE p_kc_UseHttp  @wk_url varchar(255),@outText varchar(255) out

AS
begin

declare @returnText varchar(500),
@status int,
@urlstr varchar(255)


select @wk_url = 'http://10.2.8.1/api/GetBoBoPayPDF?rpt=&wk_cp_no=2010300001'

set @urlstr = 'http://172.17.5.14:9090:df/sendDataToIVR.action?parametersStr='+@wk_url+'&ifaceType=4';
EXEC  p_kc_HttpRequestData_ @urlstr,@status OUTPUT ,@returnText OUTPUT
 
 SET @outText = @returnText
 print @returnText;

END
