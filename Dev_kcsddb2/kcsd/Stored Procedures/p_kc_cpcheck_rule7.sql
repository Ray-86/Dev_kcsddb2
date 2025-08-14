-- =============================================
-- 2021-03-23 連結檢查檢查ID歷史紀錄
-- 2021-03-03 連結檢查連結本人或保1或保2
-- 2015-09-18 自動判斷婉拒名單，法務件
-- =============================================

CREATE	PROCEDURE [kcsd].[p_kc_cpcheck_rule7] @pm_cp_no varchar(10)
AS
	UPDATE kcsd.kc_cpdata SET kc_black_flag = null,kc_black_flag1 = null,kc_black_flag2 = null,kc_lawc_flag = null,kc_lawc_flag1 = null,kc_lawc_flag2 = null
	WHERE kc_cp_no = @pm_cp_no

DECLARE @wk_id_no0 varchar(10),
		@wk_id_no1 varchar(10),
		@wk_id_no2 varchar(10)

--拒往檢查 ([R]拒往、[B]婉拒、[N]正常 kc_black_flag)
SELECT @wk_id_no0 = kc_id_no  FROM kcsd.kc_cpdata WHERE kc_cp_no = @pm_cp_no AND kc_id_no IS NOT NULL
SELECT @wk_id_no1 = kc_id_no1 FROM kcsd.kc_cpdata WHERE kc_cp_no = @pm_cp_no AND kc_id_no IS NOT NULL
SELECT @wk_id_no2 = kc_id_no2 FROM kcsd.kc_cpdata WHERE kc_cp_no = @pm_cp_no AND kc_id_no IS NOT NULL

IF (@wk_id_no0 is not null)
BEGIN
	UPDATE kcsd.kc_cpdata SET kc_black_flag = 'N' WHERE kc_cp_no = @pm_cp_no AND kc_id_no IS NOT NULL
	UPDATE kcsd.kc_cpdata SET kc_black_flag = i.kc_black_flag
	FROM (
		SELECT TOP 1 c.kc_cp_no,p.kc_case_no,
		CASE WHEN p.kc_cust_type ='BU' THEN 'R' ELSE CASE WHEN p.kc_cust_type ='B' THEN 'B' ELSE 'N' END END as kc_black_flag,
		CASE WHEN p.kc_cust_type ='BU' THEN 1 ELSE CASE WHEN p.kc_cust_type ='B' THEN 2 ELSE 3 END END as black_flag_order
		FROM kcsd.kc_cpdata c left join kcsd.kc_cpresult p on p.kc_cp_no = c.kc_cp_no
		WHERE c.kc_cp_no = @pm_cp_no and (p.kc_case_no = c.kc_id_no OR p.kc_case_no = c.kc_id2_no)
		ORDER BY black_flag_order) as i
	WHERE i.kc_cp_no = kcsd.kc_cpdata.kc_cp_no 
	and (i.kc_case_no = kcsd.kc_cpdata.kc_id_no OR i.kc_case_no = kcsd.kc_cpdata.kc_id2_no)
END

IF (@wk_id_no1 is not null)
BEGIN
	UPDATE kcsd.kc_cpdata SET kc_black_flag1 = 'N' WHERE kc_cp_no = @pm_cp_no AND kc_id_no1 IS NOT NULL
	UPDATE kcsd.kc_cpdata SET kc_black_flag1 = i.kc_black_flag
	FROM (
		SELECT TOP 1 c.kc_cp_no,p.kc_case_no,
		CASE WHEN p.kc_cust_type ='BU' THEN 'R' ELSE CASE WHEN p.kc_cust_type ='B' THEN 'B' ELSE 'N' END END as kc_black_flag,
		CASE WHEN p.kc_cust_type ='BU' THEN 1 ELSE CASE WHEN p.kc_cust_type ='B' THEN 2 ELSE 3 END END as black_flag_order
		FROM kcsd.kc_cpdata c left join kcsd.kc_cpresult p on p.kc_cp_no = c.kc_cp_no
		WHERE c.kc_cp_no = @pm_cp_no and (p.kc_case_no = c.kc_id_no1 OR p.kc_case_no = c.kc_id2_no1)
		ORDER BY black_flag_order) as i
	WHERE i.kc_cp_no = kcsd.kc_cpdata.kc_cp_no 
	and (i.kc_case_no = kcsd.kc_cpdata.kc_id_no1 OR i.kc_case_no = kcsd.kc_cpdata.kc_id2_no1)
END

IF (@wk_id_no2 is not null)
BEGIN
	UPDATE kcsd.kc_cpdata SET kc_black_flag2 = 'N' WHERE kc_cp_no = @pm_cp_no AND kc_id_no2 IS NOT NULL
	UPDATE kcsd.kc_cpdata SET kc_black_flag2 = i.kc_black_flag
	FROM (
		SELECT TOP 1 c.kc_cp_no,p.kc_case_no,
		CASE WHEN p.kc_cust_type ='BU' THEN 'R' ELSE CASE WHEN p.kc_cust_type ='B' THEN 'B' ELSE 'N' END END as kc_black_flag,
		CASE WHEN p.kc_cust_type ='BU' THEN 1 ELSE CASE WHEN p.kc_cust_type ='B' THEN 2 ELSE 3 END END as black_flag_order
		FROM kcsd.kc_cpdata c left join kcsd.kc_cpresult p on p.kc_cp_no = c.kc_cp_no
		WHERE c.kc_cp_no = @pm_cp_no and (p.kc_case_no = c.kc_id_no2 OR p.kc_case_no = c.kc_id2_no2)
		ORDER BY black_flag_order) as i
	WHERE i.kc_cp_no = kcsd.kc_cpdata.kc_cp_no 
	and (i.kc_case_no = kcsd.kc_cpdata.kc_id_no2 OR i.kc_case_no = kcsd.kc_cpdata.kc_id2_no2)
END

--連結計算
DECLARE	
@wk_id_no		varchar(10),
@wk_lawc_flag	varchar(10),
@wk_link_cnt	int,
@rowid			int,
@wk_id2_no		varchar(10)

DECLARE c1 CURSOR FOR
	SELECT 1 as rowid, kc_id_no,  kc_id2_no  from kcsd.kc_cpdata WHERE kc_cp_no = @pm_cp_no AND kc_id_no  IS NOT NULL
	UNION
	SELECT 2 as rowid, kc_id_no1, kc_id2_no1 from kcsd.kc_cpdata WHERE kc_cp_no = @pm_cp_no AND kc_id_no1 IS NOT NULL
	UNION
	SELECT 3 as rowid, kc_id_no2, kc_id2_no2 from kcsd.kc_cpdata WHERE kc_cp_no = @pm_cp_no AND kc_id_no2 IS NOT NULL
OPEN c1
FETCH NEXT FROM c1 INTO @rowid, @wk_id_no, @wk_id2_no

WHILE (@@FETCH_STATUS = 0)
BEGIN

--其他	
	SELECT @wk_lawc_flag = 'H'
--無連結
	SELECT @wk_link_cnt = count(*)
	FROM kcsd.kc_cpresult p
	WHERE  
	p.kc_cp_no = @pm_cp_no AND
	(p.kc_id_no IN (SELECT DISTINCT x.kc_id_no FROM kcsd.kc_customers x WHERE EXISTS ( 
	select 'x' FROM kcsd.kc_customers c WHERE x.kc_case_no = c.kc_case_no and x.kc_cust_type = c.kc_cust_type and c.kc_id_no in (@wk_id_no, @wk_id2_no))) 
	OR p.kc_id_no1 IN (SELECT DISTINCT x.kc_id_no FROM kcsd.kc_customers x WHERE EXISTS ( 
	select 'x' FROM kcsd.kc_customers c WHERE x.kc_case_no = c.kc_case_no and x.kc_cust_type = c.kc_cust_type and c.kc_id_no in (@wk_id_no, @wk_id2_no)))
	OR p.kc_id_no2 IN (SELECT DISTINCT x.kc_id_no FROM kcsd.kc_customers x WHERE EXISTS ( 
	select 'x' FROM kcsd.kc_customers c WHERE x.kc_case_no = c.kc_case_no and x.kc_cust_type = c.kc_cust_type and c.kc_id_no in (@wk_id_no, @wk_id2_no))))
	
	IF @wk_link_cnt = 0 SELECT @wk_lawc_flag = 'A'
--退件
	SELECT @wk_lawc_flag = 'B'
	FROM kcsd.kc_cpresult p,kcsd.kc_cpdata c
	WHERE  
	p.kc_case_no = c.kc_cp_no AND
	(SELECT count(*) FROM kcsd.kc_cpresult WHERE kc_cp_no = @pm_cp_no AND kc_id_no = @wk_id_no AND kc_cust_type = 'C') =0 AND
	p.kc_cp_no = @pm_cp_no AND
	p.kc_cust_type = 'CP' AND
	c.kc_apply_stat = 'R' AND
	(p.kc_id_no IN (SELECT DISTINCT x.kc_id_no FROM kcsd.kc_customers x WHERE EXISTS ( 
	select 'x' FROM kcsd.kc_customers c WHERE x.kc_case_no = c.kc_case_no and x.kc_cust_type = c.kc_cust_type and c.kc_id_no in (@wk_id_no, @wk_id2_no))) 
	OR p.kc_id_no1 IN (SELECT DISTINCT x.kc_id_no FROM kcsd.kc_customers x WHERE EXISTS ( 
	select 'x' FROM kcsd.kc_customers c WHERE x.kc_case_no = c.kc_case_no and x.kc_cust_type = c.kc_cust_type and c.kc_id_no in (@wk_id_no, @wk_id2_no)))
	OR p.kc_id_no2 IN (SELECT DISTINCT x.kc_id_no FROM kcsd.kc_customers x WHERE EXISTS ( 
	select 'x' FROM kcsd.kc_customers c WHERE x.kc_case_no = c.kc_case_no and x.kc_cust_type = c.kc_cust_type and c.kc_id_no in (@wk_id_no, @wk_id2_no))))
--正常
	SELECT @wk_lawc_flag = 'C'
	FROM kcsd.kc_cpresult p ,kcsd.kc_customerloan c
	WHERE  
	p.kc_case_no = c.kc_case_no AND
	p.kc_cp_no = @pm_cp_no AND
	p.kc_cust_type = 'C' AND
	c.kc_loan_stat NOT IN ('G','D') AND
	c.kc_break_amt2 <1000 AND
	(p.kc_id_no IN (SELECT DISTINCT x.kc_id_no FROM kcsd.kc_customers x WHERE EXISTS ( 
	select 'x' FROM kcsd.kc_customers c WHERE x.kc_case_no = c.kc_case_no and x.kc_cust_type = c.kc_cust_type and c.kc_id_no in (@wk_id_no, @wk_id2_no))) 
	OR p.kc_id_no1 IN (SELECT DISTINCT x.kc_id_no FROM kcsd.kc_customers x WHERE EXISTS ( 
	select 'x' FROM kcsd.kc_customers c WHERE x.kc_case_no = c.kc_case_no and x.kc_cust_type = c.kc_cust_type and c.kc_id_no in (@wk_id_no, @wk_id2_no)))
	OR p.kc_id_no2 IN (SELECT DISTINCT x.kc_id_no FROM kcsd.kc_customers x WHERE EXISTS ( 
	select 'x' FROM kcsd.kc_customers c WHERE x.kc_case_no = c.kc_case_no and x.kc_cust_type = c.kc_cust_type and c.kc_id_no in (@wk_id_no, @wk_id2_no))))
--違約
	SELECT @wk_lawc_flag = 'D'
	FROM kcsd.kc_cpresult p ,kcsd.kc_customerloan c
	WHERE  
	p.kc_case_no = c.kc_case_no AND
	p.kc_cp_no = @pm_cp_no AND
	p.kc_cust_type = 'C' AND
	c.kc_loan_stat NOT IN ('G','D') AND
	c.kc_break_amt2 >=1000 AND
	(p.kc_id_no IN (SELECT DISTINCT x.kc_id_no FROM kcsd.kc_customers x WHERE EXISTS ( 
	select 'x' FROM kcsd.kc_customers c WHERE x.kc_case_no = c.kc_case_no and x.kc_cust_type = c.kc_cust_type and c.kc_id_no in (@wk_id_no, @wk_id2_no))) 
	OR p.kc_id_no1 IN (SELECT DISTINCT x.kc_id_no FROM kcsd.kc_customers x WHERE EXISTS ( 
	select 'x' FROM kcsd.kc_customers c WHERE x.kc_case_no = c.kc_case_no and x.kc_cust_type = c.kc_cust_type and c.kc_id_no in (@wk_id_no, @wk_id2_no)))
	OR p.kc_id_no2 IN (SELECT DISTINCT x.kc_id_no FROM kcsd.kc_customers x WHERE EXISTS ( 
	select 'x' FROM kcsd.kc_customers c WHERE x.kc_case_no = c.kc_case_no and x.kc_cust_type = c.kc_cust_type and c.kc_id_no in (@wk_id_no, @wk_id2_no))))
--繳款中
	SELECT @wk_lawc_flag = 'E'
	FROM kcsd.kc_cpresult p ,kcsd.kc_customerloan c
	WHERE  
	p.kc_case_no = c.kc_case_no AND
	p.kc_cp_no = @pm_cp_no AND
	p.kc_cust_type = 'C' AND
	c.kc_loan_stat IN ('G') AND
	(p.kc_id_no IN (SELECT DISTINCT x.kc_id_no FROM kcsd.kc_customers x WHERE EXISTS ( 
	select 'x' FROM kcsd.kc_customers c WHERE x.kc_case_no = c.kc_case_no and x.kc_cust_type = c.kc_cust_type and c.kc_id_no in (@wk_id_no, @wk_id2_no))) 
	OR p.kc_id_no1 IN (SELECT DISTINCT x.kc_id_no FROM kcsd.kc_customers x WHERE EXISTS ( 
	select 'x' FROM kcsd.kc_customers c WHERE x.kc_case_no = c.kc_case_no and x.kc_cust_type = c.kc_cust_type and c.kc_id_no in (@wk_id_no, @wk_id2_no)))
	OR p.kc_id_no2 IN (SELECT DISTINCT x.kc_id_no FROM kcsd.kc_customers x WHERE EXISTS ( 
	select 'x' FROM kcsd.kc_customers c WHERE x.kc_case_no = c.kc_case_no and x.kc_cust_type = c.kc_cust_type and c.kc_id_no in (@wk_id_no, @wk_id2_no))))
--催收
	SELECT @wk_lawc_flag = 'F'
	FROM kcsd.kc_cpresult p ,kcsd.kc_customerloan c
	WHERE  
	p.kc_case_no = c.kc_case_no AND
	SUBSTRING(c.kc_pusher_code,1,1) ='P' AND
	p.kc_cp_no = @pm_cp_no AND
	p.kc_cust_type = 'C' AND
	(p.kc_id_no IN (SELECT DISTINCT x.kc_id_no FROM kcsd.kc_customers x WHERE EXISTS ( 
	select 'x' FROM kcsd.kc_customers c WHERE x.kc_case_no = c.kc_case_no and x.kc_cust_type = c.kc_cust_type and c.kc_id_no in (@wk_id_no, @wk_id2_no))) 
	OR p.kc_id_no1 IN (SELECT DISTINCT x.kc_id_no FROM kcsd.kc_customers x WHERE EXISTS ( 
	select 'x' FROM kcsd.kc_customers c WHERE x.kc_case_no = c.kc_case_no and x.kc_cust_type = c.kc_cust_type and c.kc_id_no in (@wk_id_no, @wk_id2_no)))
	OR p.kc_id_no2 IN (SELECT DISTINCT x.kc_id_no FROM kcsd.kc_customers x WHERE EXISTS ( 
	select 'x' FROM kcsd.kc_customers c WHERE x.kc_case_no = c.kc_case_no and x.kc_cust_type = c.kc_cust_type and c.kc_id_no in (@wk_id_no, @wk_id2_no))))
--法務
	SELECT @wk_lawc_flag = 'G'
	FROM kcsd.kc_cpresult p ,kcsd.kc_customerloan c
	WHERE  
	p.kc_case_no = c.kc_case_no AND
	SUBSTRING(c.kc_pusher_code,1,1) ='L' AND
	p.kc_cp_no = @pm_cp_no AND	 
	p.kc_cust_type = 'C' AND
	(p.kc_id_no IN (SELECT DISTINCT x.kc_id_no FROM kcsd.kc_customers x WHERE EXISTS ( 
	select 'x' FROM kcsd.kc_customers c WHERE x.kc_case_no = c.kc_case_no and x.kc_cust_type = c.kc_cust_type and c.kc_id_no in (@wk_id_no, @wk_id2_no))) 
	OR p.kc_id_no1 IN (SELECT DISTINCT x.kc_id_no FROM kcsd.kc_customers x WHERE EXISTS ( 
	select 'x' FROM kcsd.kc_customers c WHERE x.kc_case_no = c.kc_case_no and x.kc_cust_type = c.kc_cust_type and c.kc_id_no in (@wk_id_no, @wk_id2_no)))
	OR p.kc_id_no2 IN (SELECT DISTINCT x.kc_id_no FROM kcsd.kc_customers x WHERE EXISTS ( 
	select 'x' FROM kcsd.kc_customers c WHERE x.kc_case_no = c.kc_case_no and x.kc_cust_type = c.kc_cust_type and c.kc_id_no in (@wk_id_no, @wk_id2_no))))

	IF @rowid = 1 
		UPDATE kcsd.kc_cpdata SET kc_lawc_flag = @wk_lawc_flag WHERE kc_cp_no = @pm_cp_no
	ELSE IF @rowid = 2 
		UPDATE kcsd.kc_cpdata SET kc_lawc_flag1 = @wk_lawc_flag WHERE kc_cp_no = @pm_cp_no
	ELSE IF @rowid = 3
		UPDATE kcsd.kc_cpdata SET kc_lawc_flag2 = @wk_lawc_flag WHERE kc_cp_no = @pm_cp_no

FETCH NEXT FROM c1 INTO @rowid, @wk_id_no, @wk_id2_no
END
CLOSE c1
DEALLOCATE c1
	
	


/*
--正常[N]
	IF (SELECT COUNT(kc_id_no) FROM kcsd.kc_cpdata WHERE kc_cp_no = @pm_cp_no) >0
	BEGIN
		UPDATE kcsd.kc_cpdata SET	kc_black_flag = 'N',kc_decline_flag = 'N',kc_lawc_flag = 'N' WHERE kc_cp_no = @pm_cp_no	
	END

	IF (SELECT COUNT(kc_id_no1) FROM kcsd.kc_cpdata WHERE kc_cp_no = @pm_cp_no) >0
	BEGIN
		UPDATE kcsd.kc_cpdata SET	kc_black_flag1 = 'N',kc_decline_flag1 = 'N',kc_lawc_flag1 = 'N' WHERE kc_cp_no = @pm_cp_no	
	END

	IF (SELECT COUNT(kc_id_no2) FROM kcsd.kc_cpdata WHERE kc_cp_no = @pm_cp_no) >0
	BEGIN
		UPDATE kcsd.kc_cpdata SET	kc_black_flag2 = 'N',kc_decline_flag2 = 'N',kc_lawc_flag2 = 'N' WHERE kc_cp_no = @pm_cp_no	
	END
--婉拒[B]
	UPDATE kcsd.kc_cpdata SET kc_black_flag = 'Y'
	WHERE
	kc_cp_no = @pm_cp_no  AND
	kc_id_no IN (
	SELECT b.kc_id_no FROM kcsd.kc_cpresult p ,kcsd.kc_blacklist b WHERE  p.kc_case_no = b.kc_id_no AND p.kc_cp_no = @pm_cp_no AND p.kc_cust_type = 'B'
	)

	UPDATE kcsd.kc_cpdata SET kc_black_flag1 = 'Y'
	WHERE
	kc_cp_no = @pm_cp_no  AND
	kc_id_no1 IN (
	SELECT b.kc_id_no FROM kcsd.kc_cpresult p ,kcsd.kc_blacklist b WHERE  p.kc_case_no = b.kc_id_no AND p.kc_cp_no = @pm_cp_no AND p.kc_cust_type = 'B'
	)
	
	UPDATE kcsd.kc_cpdata SET kc_black_flag2 = 'Y'
	WHERE
	kc_cp_no = @pm_cp_no  AND
	kc_id_no2 IN (
	SELECT b.kc_id_no FROM kcsd.kc_cpresult p ,kcsd.kc_blacklist b WHERE  p.kc_case_no = b.kc_id_no AND p.kc_cp_no = @pm_cp_no AND p.kc_cust_type = 'B'
	)
--拒往[R]
	UPDATE kcsd.kc_cpdata SET kc_black_flag = 'Y'
	WHERE
	kc_cp_no = @pm_cp_no  AND
	kc_id_no IN (
	SELECT b.kc_id_no FROM kcsd.kc_cpresult p ,kcsd.kc_blacklist b WHERE  p.kc_case_no = b.kc_id_no AND p.kc_cp_no = @pm_cp_no AND p.kc_cust_type = 'BU'
	)

	UPDATE kcsd.kc_cpdata SET kc_black_flag1 = 'Y'
	WHERE
	kc_cp_no = @pm_cp_no  AND
	kc_id_no1 IN (
	SELECT b.kc_id_no FROM kcsd.kc_cpresult p ,kcsd.kc_blacklist b WHERE  p.kc_case_no = b.kc_id_no AND p.kc_cp_no = @pm_cp_no AND p.kc_cust_type = 'BU'
	)
	
	UPDATE kcsd.kc_cpdata SET kc_black_flag2 = 'Y'
	WHERE
	kc_cp_no = @pm_cp_no  AND
	kc_id_no2 IN (
	SELECT b.kc_id_no FROM kcsd.kc_cpresult p ,kcsd.kc_blacklist b WHERE  p.kc_case_no = b.kc_id_no AND p.kc_cp_no = @pm_cp_no AND p.kc_cust_type = 'BU'
	)
*/
/*
--連結檢查
	--催收
	UPDATE kcsd.kc_cpdata SET kc_lawc_flag = 'P'
	WHERE 
	kc_cp_no = @pm_cp_no  AND
	kc_id_no IN (
	select p.kc_id_no from kcsd.kc_cpresult p ,kcsd.kc_customerloan c WHERE  p.kc_case_no = c.kc_case_no and SUBSTRING(c.kc_pusher_code,1,1) ='P'  AND p.kc_cp_no = @pm_cp_no AND p.kc_cust_type = 'C'
	UNION
	select p.kc_id_no1 from kcsd.kc_cpresult p ,kcsd.kc_customerloan c WHERE  p.kc_case_no = c.kc_case_no and SUBSTRING(c.kc_pusher_code,1,1) ='P'  AND p.kc_cp_no = @pm_cp_no AND p.kc_cust_type = 'C'
	UNION
	select p.kc_id_no2 from kcsd.kc_cpresult p ,kcsd.kc_customerloan c WHERE  p.kc_case_no = c.kc_case_no and SUBSTRING(c.kc_pusher_code,1,1) ='P'  AND p.kc_cp_no = @pm_cp_no AND p.kc_cust_type = 'C'
	)
	UPDATE kcsd.kc_cpdata SET kc_lawc_flag1 = 'P'
	WHERE 		
	kc_cp_no = @pm_cp_no  AND
	kc_id_no1 IN (
	select p.kc_id_no from kcsd.kc_cpresult p ,kcsd.kc_customerloan c WHERE  p.kc_case_no = c.kc_case_no and SUBSTRING(c.kc_pusher_code,1,1) ='P'  AND p.kc_cp_no = @pm_cp_no AND p.kc_cust_type = 'C'
	UNION
	select p.kc_id_no1 from kcsd.kc_cpresult p ,kcsd.kc_customerloan c WHERE  p.kc_case_no = c.kc_case_no and SUBSTRING(c.kc_pusher_code,1,1) ='P'  AND p.kc_cp_no = @pm_cp_no AND p.kc_cust_type = 'C'
	UNION
	select p.kc_id_no2 from kcsd.kc_cpresult p ,kcsd.kc_customerloan c WHERE  p.kc_case_no = c.kc_case_no and SUBSTRING(c.kc_pusher_code,1,1) ='P'  AND p.kc_cp_no = @pm_cp_no AND p.kc_cust_type = 'C'
	)
	UPDATE kcsd.kc_cpdata SET kc_lawc_flag2 = 'P'
	WHERE  
	kc_cp_no = @pm_cp_no  AND
	kc_id_no2 IN (
	select p.kc_id_no from kcsd.kc_cpresult p ,kcsd.kc_customerloan c WHERE  p.kc_case_no = c.kc_case_no and SUBSTRING(c.kc_pusher_code,1,1) ='P'  AND p.kc_cp_no = @pm_cp_no AND p.kc_cust_type = 'C'
	UNION
	select p.kc_id_no1 from kcsd.kc_cpresult p ,kcsd.kc_customerloan c WHERE  p.kc_case_no = c.kc_case_no and SUBSTRING(c.kc_pusher_code,1,1) ='P'  AND p.kc_cp_no = @pm_cp_no AND p.kc_cust_type = 'C'
	UNION
	select p.kc_id_no2 from kcsd.kc_cpresult p ,kcsd.kc_customerloan c WHERE  p.kc_case_no = c.kc_case_no and SUBSTRING(c.kc_pusher_code,1,1) ='P'  AND p.kc_cp_no = @pm_cp_no AND p.kc_cust_type = 'C'
	)
	--法務
	UPDATE kcsd.kc_cpdata SET kc_lawc_flag = 'L'
	WHERE 
	kc_cp_no = @pm_cp_no  AND
	kc_id_no IN (
	select p.kc_id_no from kcsd.kc_cpresult p ,kcsd.kc_customerloan c WHERE  p.kc_case_no = c.kc_case_no and SUBSTRING(c.kc_pusher_code,1,1) ='L'  AND p.kc_cp_no = @pm_cp_no AND p.kc_cust_type = 'C'
	UNION
	select p.kc_id_no1 from kcsd.kc_cpresult p ,kcsd.kc_customerloan c WHERE  p.kc_case_no = c.kc_case_no and SUBSTRING(c.kc_pusher_code,1,1) ='L'  AND p.kc_cp_no = @pm_cp_no AND p.kc_cust_type = 'C'
	UNION
	select p.kc_id_no2 from kcsd.kc_cpresult p ,kcsd.kc_customerloan c WHERE  p.kc_case_no = c.kc_case_no and SUBSTRING(c.kc_pusher_code,1,1) ='L'  AND p.kc_cp_no = @pm_cp_no AND p.kc_cust_type = 'C'
	)
	UPDATE kcsd.kc_cpdata SET kc_lawc_flag1 = 'L'
	WHERE 		
	kc_cp_no = @pm_cp_no  AND
	kc_id_no1 IN (
	select p.kc_id_no from kcsd.kc_cpresult p ,kcsd.kc_customerloan c WHERE  p.kc_case_no = c.kc_case_no and SUBSTRING(c.kc_pusher_code,1,1) ='L'  AND p.kc_cp_no = @pm_cp_no AND p.kc_cust_type = 'C'
	UNION
	select p.kc_id_no1 from kcsd.kc_cpresult p ,kcsd.kc_customerloan c WHERE  p.kc_case_no = c.kc_case_no and SUBSTRING(c.kc_pusher_code,1,1) ='L'  AND p.kc_cp_no = @pm_cp_no AND p.kc_cust_type = 'C'
	UNION
	select p.kc_id_no2 from kcsd.kc_cpresult p ,kcsd.kc_customerloan c WHERE  p.kc_case_no = c.kc_case_no and SUBSTRING(c.kc_pusher_code,1,1) ='L'  AND p.kc_cp_no = @pm_cp_no AND p.kc_cust_type = 'C'
	)
	UPDATE kcsd.kc_cpdata SET kc_lawc_flag2 = 'L'
	WHERE  
	kc_cp_no = @pm_cp_no  AND
	kc_id_no2 IN (
	select p.kc_id_no from kcsd.kc_cpresult p ,kcsd.kc_customerloan c WHERE  p.kc_case_no = c.kc_case_no and SUBSTRING(c.kc_pusher_code,1,1) ='L'  AND p.kc_cp_no = @pm_cp_no AND p.kc_cust_type = 'C'
	UNION
	select p.kc_id_no1 from kcsd.kc_cpresult p ,kcsd.kc_customerloan c WHERE  p.kc_case_no = c.kc_case_no and SUBSTRING(c.kc_pusher_code,1,1) ='L'  AND p.kc_cp_no = @pm_cp_no AND p.kc_cust_type = 'C'
	UNION
	select p.kc_id_no2 from kcsd.kc_cpresult p ,kcsd.kc_customerloan c WHERE  p.kc_case_no = c.kc_case_no and SUBSTRING(c.kc_pusher_code,1,1) ='L'  AND p.kc_cp_no = @pm_cp_no AND p.kc_cust_type = 'C'
	)
*/