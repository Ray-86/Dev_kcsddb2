-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [kcsd].[p_kc_pushassign_LtoLHLF] @pm_run_code varchar(10)=NULL, @pm_pusher_date datetime=NULL
AS
BEGIN
	
DECLARE
	@wk_case_no	varchar(10),
	@wk_max_paydate	datetime,	-- 最近一次繳款日
	@wk_delay_code	varchar(4),
	@wk_pusher_code	varchar(6),	-- M0 
	@wk_pusher_date	datetime,	-- 指派日
	@wk_area_code	varchar(2),	-- 業務換區用
	@wk_expt_date	datetime,	--當期因繳日
	@wk_over_amt		int


--DECLARE	@pm_run_code	varchar(10)

	
CREATE TABLE #tmp_pushassign_test
(kc_case_no	varchar(10),
kc_area_code varchar(10),
kc_delay_code	varchar(4),
kc_pusher_code	varchar(6),
kc_pusher_date	smalldatetime,
kc_over_amt		int,
kc_expt_date	smalldatetime
)




DECLARE	cursor_case_no	CURSOR FOR

select p.kc_case_no,ISNULL(l.max_paydate,kc_buy_date) as min_paydate from kcsd.kc_pushassign p
left join  kcsd.kc_customerloan c on p.kc_case_no = c.kc_case_no
left join  (select kc_case_no,MAX(kc_pay_date) max_paydate from kcsd.kc_loanpayment group by kc_case_no) l on p.kc_case_no = l.kc_case_no
where kc_stop_date is null
and p.kc_pusher_code in ('L01','L02','L03','L05','L06','L07','L09','L12')
and kc_push_sort = 'E0'

ORDER BY p.kc_case_no

OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no,@wk_max_paydate

WHILE (@@FETCH_STATUS = 0)
BEGIN
		SELECT	@wk_pusher_code = NULL,  @wk_area_code = NULL, @wk_over_amt = 0
	
		SELECT	  @wk_area_code = kc_area_code ,@wk_over_amt = kc_over_amt 
		FROM	kcsd.kc_customerloan
		WHERE	kc_case_no = @wk_case_no

		--取逾期代碼M0~MX
		EXECUTE kcsd.p_kc_pushassign_calcm @wk_case_no, @wk_delay_code OUTPUT

		select @wk_pusher_code = case when DATEADD(year, 5, @wk_max_paydate) < GETDATE() then 'LH' else 'LF' end 
		SELECT @wk_pusher_date = CONVERT(varchar(20), GETDATE(), 23)

			--取當期應繳日
			SELECT @wk_expt_date = min(kc_expt_date) FROM kcsd.kc_loanpayment WHERE kc_case_no  = @wk_case_no AND kc_pay_date IS NULL

			IF	@pm_run_code = 'EXECUTE'
			BEGIN
				-- 1.結束先前指派, 停派日為 新指派日前1日
				UPDATE	kcsd.kc_pushassign
				SET	kc_stop_date = DATEADD(day, -1, @wk_pusher_date)
				WHERE	kc_case_no = @wk_case_no
				AND	kc_stop_date IS NULL		

				-- 2.新增指派
				INSERT	kcsd.kc_pushassign
					(kc_case_no,kc_area_code, kc_strt_date, kc_pusher_code, kc_delay_code,kc_updt_user, kc_updt_date,kc_expt_date)
				VALUES	(@wk_case_no,@wk_area_code, @wk_pusher_date, @wk_pusher_code, @wk_delay_code,USER, GETDATE(),@wk_expt_date )

				-- 3.修改主檔
				UPDATE kcsd.kc_customerloan
				SET	kc_pusher_code = @wk_pusher_code,
					kc_pusher_date = @wk_pusher_date,
					kc_delay_code = @wk_delay_code,
					kc_push_sort = 'X',
					kc_updt_user = USER,
					kc_updt_date = GETDATE()
				WHERE kc_case_no = @wk_case_no

				--4.存測試資料
				INSERT	#tmp_pushassign_test
					(kc_case_no,kc_area_code, kc_delay_code, kc_pusher_code, kc_pusher_date, kc_over_amt,kc_expt_date)
				VALUES	(@wk_case_no, @wk_area_code, @wk_delay_code, @wk_pusher_code, @wk_pusher_date, @wk_over_amt,@wk_expt_date)	
			END

			ELSE
			BEGIN
				--存測試資料
				INSERT	#tmp_pushassign_test
					(kc_case_no,kc_area_code, kc_delay_code, kc_pusher_code, kc_pusher_date, kc_over_amt,kc_expt_date)
				VALUES	(@wk_case_no, @wk_area_code, @wk_delay_code, @wk_pusher_code, @wk_pusher_date, @wk_over_amt,@wk_expt_date)	
			END
		



	FETCH NEXT FROM cursor_case_no INTO  @wk_case_no,@wk_max_paydate
END


DEALLOCATE	cursor_case_no

	SELECT	*
	FROM	#tmp_pushassign_test
	ORDER BY kc_over_amt DESC
	
	--金額合計
	SELECT kc_delay_code,kc_pusher_code,count(*) as cnt,sum(kc_over_amt) as kc_over_amt
	FROM	#tmp_pushassign_test
	group by kc_delay_code,kc_pusher_code
	order by kc_delay_code,kc_pusher_code

DROP TABLE #tmp_pushassign_test

END
