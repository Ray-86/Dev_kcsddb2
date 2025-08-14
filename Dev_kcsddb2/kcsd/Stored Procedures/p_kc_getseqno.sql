-- =============================================
-- 2014-04-02 取號機制
-- 
--exec kcsd.p_kc_getseqno 'insuno','','Y4MMDDAR',4,1,1,'前置碼'		無分公司
--exec kcsd.p_kc_getseqno 'insuno','01','Y4MMDDAR',4,1,1,'前置碼'	分公司
--                                            代號,分公司,日期代碼,流水號位數,流水號每次增加數,流水號是否每日歸零
-- =============================================
CREATE       PROCEDURE [kcsd].[p_kc_getseqno] @USERTYPE varchar(12)='',@USERAREA  varchar(2)='',@USEPREFIX varchar(10)='',@USERLENGTH INT = 0,@USERCOUNT INT = 0,@USERRETURN INT = 0,@USERPREFIX varchar(10)=''
AS
DECLARE	@TO_NO INT,
		@kc_prefix_no varchar(10),
		@kc_area_code varchar(2),
		@PREFIX varchar(10),
		@NO_LENGTH int,
		@COUNT int,
		@kc_date_no smalldatetime

SELECT @PREFIX = ''

--檢查流水號是否存在
IF NOT EXISTS (SELECT * FROM kc_systemseq WITH (NOLOCK) WHERE kc_type_no=@USERTYPE and kc_area_code=@USERAREA and kc_prefix_no = @USEPREFIX and kc_seq_len=@USERLENGTH and kc_seq_cnt=@USERCOUNT) 
BEGIN
	INSERT INTO kc_systemseq VALUES(@USERTYPE,@USERAREA,@USEPREFIX,@USERLENGTH,@USERCOUNT, 0,CONVERT(varchar(100), GETDATE(), 23))
END

--每日序號歸0
IF @USERRETURN = 1
BEGIN
	SELECT @kc_date_no = kc_date_no FROM kc_systemseq WHERE kc_type_no=@USERTYPE and kc_area_code=@USERAREA and kc_prefix_no = @USEPREFIX and kc_seq_len=@USERLENGTH and kc_seq_cnt=@USERCOUNT
	IF @kc_date_no <>CONVERT(varchar(100), GETDATE(), 23)
	BEGIN
		UPDATE kc_systemseq SET kc_current_no = 0
	END
END

BEGIN TRAN

	--取前置碼,流水號長度,增加值
	SELECT @kc_prefix_no = kc_prefix_no,@NO_LENGTH = kc_seq_len,@COUNT = kc_seq_cnt  FROM kc_systemseq WHERE kc_type_no=@USERTYPE and kc_area_code=@USERAREA and kc_prefix_no = @USEPREFIX and kc_seq_len=@USERLENGTH and kc_seq_cnt=@USERCOUNT
	IF @kc_prefix_no is not null
	BEGIN
		IF CHARINDEX('Y2',@kc_prefix_no) >0 SELECT @PREFIX = @PREFIX + RIGHT('0' + RTRIM(YEAR(GETDATE())), 2)
		IF CHARINDEX('Y4',@kc_prefix_no) >0 SELECT @PREFIX = @PREFIX +  RIGHT('0' + RTRIM(YEAR(GETDATE())), 4)
		IF CHARINDEX('EE',@kc_prefix_no) >0 SELECT @PREFIX = @PREFIX +  RIGHT('0' + RTRIM(YEAR(GETDATE())-1911), 3)
		IF CHARINDEX('MM',@kc_prefix_no) >0 SELECT @PREFIX = @PREFIX + RIGHT('0' + RTRIM(MONTH(GETDATE())), 2)
		IF CHARINDEX('DD',@kc_prefix_no) >0 SELECT @PREFIX = @PREFIX + RIGHT('0' + RTRIM(DAY(GETDATE())), 2)
		IF CHARINDEX('AR',@kc_prefix_no) >0 SELECT @PREFIX = @PREFIX + @USERAREA
	END

	--取出流水號並更新資料
	UPDATE kc_systemseq
	SET kc_current_no = kc_current_no+@COUNT, @TO_NO = kc_current_no+@COUNT ,kc_date_no = CONVERT(varchar(100), GETDATE(), 23) WHERE kc_type_no=@USERTYPE and kc_area_code=@USERAREA and kc_prefix_no = @USEPREFIX and kc_seq_len=@USERLENGTH and kc_seq_cnt=@USERCOUNT
	COMMIT TRAN
	SELECT --FROM_NO=@PREFIX+@USERPREFIX + RIGHT('0000000000' + CONVERT(VARCHAR, @TO_NO-@COUNT), @NO_LENGTH) ,
                                 TO_NO=@PREFIX+@USERPREFIX + RIGHT('0000000000' + CONVERT(VARCHAR, @TO_NO), @NO_LENGTH)
