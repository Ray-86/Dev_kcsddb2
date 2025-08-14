CREATE  PROCEDURE  [dbo].[p_kc_GetATMCodeB] 
@pm_ATM_codeB varchar(20) OUTPUT,@pm_expt_fee  int ,@pm_expt_date datetime
AS
-- 假設 kc_ATM_codeB 和 kc_expt_fee 已經初始化
DECLARE @kc_ATM_codeB NVARCHAR(20) = @pm_ATM_codeB;
DECLARE @kc_expt_fee INT = @pm_expt_fee;


-- 取得當前年份和日期
DECLARE @now_yyyy NVARCHAR(4) = CONVERT(NVARCHAR(4),@pm_expt_date, 120);
DECLARE @now_MMdd NVARCHAR(4) = FORMAT(@pm_expt_date, 'MMdd');

-- 根據年份判斷是否為閏年
DECLARE @kc_ATMitem NVARCHAR(10);
SELECT @kc_ATMitem = CASE 
                        WHEN CAST(@now_yyyy AS INT) % 4 <> 0 
                        THEN RIGHT(@now_yyyy, 1) + item 
                        ELSE RIGHT(@now_yyyy, 1) + item4
                     END
FROM kcsd.kc_ATMitemlist Where Date = @now_MMdd

-- 組合 kc_ATM_codeB
SET @kc_ATM_codeB = LEFT(@kc_ATM_codeB, 4) + @kc_ATMitem + SUBSTRING(@kc_ATM_codeB, 5, 5);

-- 格式化 kc_expt_fee
DECLARE @Str_total_fee NVARCHAR(13) = FORMAT(@kc_expt_fee, '0000000000000');

-- 將 kc_ATM_codeB 和 @Str_total_fee 分解為陣列
DECLARE @Array_A NVARCHAR(13) = @kc_ATM_codeB;
DECLARE @Array_B NVARCHAR(13) = @Str_total_fee;

-- 定義 Array_C 和 Array_D
DECLARE @Array_C TABLE (id INT IDENTITY(1,1), value INT);
DECLARE @Array_D TABLE (id INT IDENTITY(1,1), value INT);

INSERT INTO @Array_C VALUES (1), (2), (3), (4), (6), (7), (8), (9), (0), (1), (2), (3), (4);
INSERT INTO @Array_D VALUES (0), (0), (0), (0), (0), (1), (2), (3), (4), (5), (6), (7), (8);

-- 計算檢查碼 chk
DECLARE @chk INT = 0;
DECLARE @i INT = 1;

WHILE @i <= 13
BEGIN
    -- 從 Array_C 和 Array_D 獲取值
    DECLARE @value_C INT = (SELECT value FROM @Array_C WHERE id = @i);
    DECLARE @value_D INT = (SELECT value FROM @Array_D WHERE id = @i);

    -- 分解字串中的數值
    DECLARE @value_A INT = CAST(SUBSTRING(@kc_ATM_codeB, @i, 1) AS INT);
    DECLARE @value_B INT = CAST(SUBSTRING(@Str_total_fee, @i, 1) AS INT);

    -- 累加計算
    SET @chk += @value_A * @value_C;
    SET @chk += @value_B * @value_D;

    SET @i += 1;
END

-- 計算 X 和修正檢查碼
DECLARE @R INT = @chk % 11;
DECLARE @X INT = CASE 
                    WHEN @R = 1 THEN 11
                    WHEN @R = 0 THEN 10
                    ELSE @R
                 END;

SET @chk = 11 - @X;

-- 組合最終結果
SET @kc_ATM_codeB += CAST(@chk AS NVARCHAR);

-- 輸出結果
SELECT @pm_ATM_codeB = @kc_ATM_codeB

SELECT @pm_ATM_codeB as kc_ATM_codeB
