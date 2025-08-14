-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [kcsd].[LetterB_BarCode3]
(
	-- Add the parameters for the function here
	@barcode1 varchar(20), @barcode2 varchar(20), @wk_case_no varchar(12), @wk_law_date datetime, @wk_over_amt int
)
RETURNS VARCHAR(25)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @checkcode VARCHAR(10) = '', --檢查碼
			@list1 VARCHAR(120) = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',
			@list2 VARCHAR(120) = '123456789123456789234567890123456789',
			@odd  int = 0,
			@even int = 0,
			--收款日空白應繳日
			--@Exptdate datetime = (SELECT MIN(kc_expt_date) FROM kcsd.kc_loanpayment WHERE kc_pay_date is NULL AND kc_case_no = @wk_case_no),
			--條碼金額 : 逾期金額 + 違約金 (500)
			@BarAmt int = (@wk_over_amt + 500),
			--帳單條碼3
			@BarCode3 VARCHAR(25),
			@i int = 0

	-- Add the T-SQL statements to compute the return value here
	SET @BarCode3 = FORMAT(year(@wk_law_date)-2011, '00') + FORMAT(@wk_law_date, 'MM') + '00' + FORMAT(@BarAmt, '000000000')
	--Bar3 公式 : (ExptDate.Year - 2011).ToString("00") + ExptDate.ToString("MM") + checkCode + (金額).ToString("000000000")
	
	--檢查條碼1
	WHILE @i < LEN(@barcode1)
	BEGIN
		if (@i % 2) = 0
			SET @odd = @odd + CAST(SUBSTRING(@list2, CHARINDEX(SUBSTRING(@barcode1, @i+1, 1), @list1), 1) AS INT)
		else
			SET @even = @even + CAST(SUBSTRING(@list2, CHARINDEX(SUBSTRING(@barcode1, @i+1, 1), @list1), 1) AS INT)

		SET @i = @i + 1
	END
	--檢查條碼2
	SET @i = 0
	WHILE @i < LEN(@barcode2)
	BEGIN
		if (@i % 2) = 0
			SET @odd = @odd + CAST(SUBSTRING(@list2, CHARINDEX(SUBSTRING(@barcode2, @i+1, 1), @list1), 1) AS INT)
		else
			SET @even = @even + CAST(SUBSTRING(@list2, CHARINDEX(SUBSTRING(@barcode2, @i+1, 1), @list1), 1) AS INT)

		SET @i = @i + 1
	END
	--檢查條碼3
	SET @i = 0
	WHILE @i < LEN(@barcode3)
	BEGIN
		if (@i % 2) = 0
			SET @odd = @odd + CAST(SUBSTRING(@list2, CHARINDEX(SUBSTRING(@barcode3, @i+1, 1), @list1), 1) AS INT)
		else
			SET @even = @even + CAST(SUBSTRING(@list2, CHARINDEX(SUBSTRING(@barcode3, @i+1, 1), @list1), 1) AS INT)

		SET @i = @i + 1
	END
	--檢查碼 : 奇數位數相加 偶數位數相加 取餘數 0為A、X 10為B、Y 其餘對照
	if (@odd % 11) = 0
		SET @checkcode = 'A'
	else if (@odd % 11) = 10
		SET @checkcode = 'B'
	else
		SET @checkcode = CAST(@odd % 11 AS VARCHAR)
	if (@even % 11) = 0
		SET @checkcode = @checkcode + 'X'
	else if (@even % 11) = 10
		SET @checkcode = @checkcode + 'Y'
	else
		SET @checkcode = @checkcode + CAST(@even % 11 AS VARCHAR)

	SET @BarCode3 = FORMAT(year(@wk_law_date)-2011, '00') + FORMAT(@wk_law_date, 'MM') + @checkcode + FORMAT(@BarAmt, '000000000')

	-- Return the result of the function
	RETURN @BarCode3

END
