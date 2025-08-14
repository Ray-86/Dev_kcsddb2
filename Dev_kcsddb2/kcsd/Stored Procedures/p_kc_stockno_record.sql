-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [kcsd].[p_kc_stockno_record]  @wk_acc_no varchar(3)=NULL
AS
BEGIN

CREATE TABLE #tmp_add
(
kc_acc_no		varchar(3),
kc_effect_date	datetime,
kc_stock_no		varchar(20),
kc_add_num		int,
kc_cut_num		int,
kc_total_num    int,
kc_stock_memo	varchar(100),
)
DECLARE  		@wk_stock_no		varchar(20),
				@wk_effect_date	    datetime,
				@wk_stock_number	varchar(10),
				@wk_source_type		varchar(2),
				@type				varchar(2),
				@wk_stock_memo		varchar(100),

				@wk_acc_target		varchar(3),
				@wk_add_num			int,
				@wk_total_num		int




		Set @wk_acc_target = ''
		Set @wk_total_num = 0

--DECLARE c1 CURSOR FOR
--select kc_acc_after as acc,kc_change_date,r.kc_stock_no,d.kc_stock_number,Case When kc_stock_price is null and kc_acc_before is null then s.Text else '轉讓買賣 出讓人-'+kc_acc_before+'('+kc_stock_price+')' END as kc_list_memo,'add' as bool
--from [kcsd].[kc_stockchangerecord] r left join [kcsd].[kc_stockdata] d on r.kc_stock_no = d.kc_stock_no 
----left join [kcsd].[kc_stockaccount] a on r.kc_acc_before = a.kc_acc_no
--left join (select Value,Text from [Zephyr.Sys].[dbo].[sys_code] where CodeType = 'StockSourceType') s on d.kc_source_type = s.Value
--UNION
--select kc_acc_before as acc,kc_change_date,r.kc_stock_no,d.kc_stock_number,'轉讓買賣 受讓人-'+kc_acc_after+'('+kc_stock_price+')' as kc_list_memo ,'cut' as bool
--from [kcsd].[kc_stockchangerecord] r left join [kcsd].[kc_stockdata] d on r.kc_stock_no = d.kc_stock_no 
----left join [kcsd].[kc_stockaccount] a on r.kc_acc_before = a.kc_acc_no
--left join (select Value,Text from [Zephyr.Sys].[dbo].[sys_code] where CodeType = 'StockSourceType') s on d.kc_source_type = s.Value
--where kc_stock_price is not null and kc_acc_before is not null
--order by acc,kc_change_date,bool
--OPEN c1
--FETCH NEXT FROM c1 INTO @wk_acc_target,@wk_change_date,@wk_stock_no,@wk_stock_number,@wk_list_memo,@wk_bool



DECLARE c1 CURSOR FOR
select a.*,b.kc_stock_number from (
Select kc_stock_no,kc_acc_no,kc_effect_date ,s.Text as kc_stock_memo,'01' as 'type'  from [kcsd].[kc_stockdata] d
left join (select Value,Text from [Zephyr.Sys].[dbo].[sys_code] where CodeType = 'StockSourceType') s on d.kc_source_type = s.Value
UNION 
Select kc_stock_no,kc_acc_after as kc_acc_no ,kc_record_date as kc_effect_date,'轉讓買賣 出讓人-'+kc_acc_before+'('+CONVERT(varchar, kc_stock_price)+')' as kc_stock_memo, '02' as 'type' from [kcsd].[kc_stockchangerecord]
UNION 
Select kc_stock_no,kc_acc_before as kc_acc_no ,kc_record_date as kc_effect_date,'轉讓買賣 受讓人-'+kc_acc_after+'('+CONVERT(varchar, kc_stock_price)+')' as kc_stock_memo, '03' as 'type' from [kcsd].[kc_stockchangerecord]
) a 
left join [kcsd].[kc_stockdata] b on a.kc_stock_no=b.kc_stock_no
--where @wk_acc_no = '' OR a.kc_acc_no = @wk_acc_no
where (@wk_acc_no = '' OR a.kc_acc_no = @wk_acc_no)
order by kc_acc_no,kc_effect_date,kc_stock_no
OPEN c1
FETCH NEXT FROM c1 INTO @wk_stock_no,@wk_acc_no,@wk_effect_date,@wk_stock_memo,@type,@wk_stock_number


WHILE @@FETCH_STATUS = 0
begin

IF @wk_acc_target = @wk_acc_no
BEGIN
IF @type = '03'
BEGIN
		Set @wk_total_num = @wk_total_num - @wk_stock_number
		INSERT INTO #tmp_add
		VALUES (@wk_acc_no, @wk_effect_date, @wk_stock_no,'',@wk_stock_number,@wk_total_num,@wk_stock_memo);
END
ELSE
BEGIN
		Set @wk_total_num =@wk_total_num + @wk_stock_number
		INSERT INTO #tmp_add
		VALUES (@wk_acc_no, @wk_effect_date, @wk_stock_no,@wk_stock_number,'',@wk_total_num,@wk_stock_memo);
END
END

ELSE
BEGIN
		SET @wk_acc_target = @wk_acc_no
IF @type = '03'
BEGIN
		Set @wk_total_num = 0 - @wk_stock_number
		INSERT INTO #tmp_add
		VALUES (@wk_acc_no, @wk_effect_date, @wk_stock_no,'',@wk_stock_number,@wk_total_num,@wk_stock_memo);
END
ELSE
BEGIN
		Set @wk_total_num = @wk_stock_number
		INSERT INTO #tmp_add
		VALUES (@wk_acc_no, @wk_effect_date, @wk_stock_no,@wk_stock_number,'',@wk_total_num,@wk_stock_memo);
END


END

FETCH NEXT FROM c1  INTO @wk_stock_no,@wk_acc_no,@wk_effect_date,@wk_stock_memo,@type,@wk_stock_number
end
CLOSE c1
DEALLOCATE c1


select * from #tmp_add  order by kc_acc_no,kc_effect_date,kc_stock_no
	   


END


DROP table #tmp_add
