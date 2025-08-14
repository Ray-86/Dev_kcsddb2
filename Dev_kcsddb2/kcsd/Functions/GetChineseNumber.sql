
CREATE function [kcsd].[GetChineseNumber] (@money numeric(14,2))
returns nvarchar(32) as
begin
    declare @money_num nvarchar(20)    --存儲金額的字符形式
        , @money_chn nvarchar(32)    --存儲金額的中文大寫形式
        , @n_chn nvarchar(1), @i int    --臨時變量
 
    select @money_chn=case when @money>=0 then '' else null end
        , @money=abs(@money)
        , @money_num=stuff(str(@money, 15, 2), 13, 1, '')    --加前置空格補齊到位（去掉小數點）
        , @i=patindex('%[1-9]%', @money_num)    --找到金額最高位
 
    while @i>=1 and @i<=14
    begin
        set @n_chn=substring(@money_num, @i, 1)   
        if @n_chn<>'0' or (substring(@money_num,@i+1,1)<>'0' and @i not in(4, 8, 12, 14))    --轉換阿拉伯數字為中文大寫形式   
            set @money_chn=@money_chn+substring('零壹貳參肆伍陸柒捌玖', @n_chn+1, 1)
        if @n_chn<>'0' or @i in(4, 8, 12)    --添加中文單位
            set @money_chn=@money_chn+substring('仟佰拾億仟佰拾萬仟佰拾元角分',@i,1)     
   
        set @i=@i+1
    end
 
    set @money_chn=replace(@money_chn, '億萬', '億')    --當金額為x億零萬時去掉萬
    if @money=0 set @money_chn='零元整'    --當金額為零時返回'零圓整'
    if @n_chn='0' set @money_chn=@money_chn+'整'    --當金額末尾為零分時以'整'結尾
 
    return @money_chn    --返回大寫金額
end
