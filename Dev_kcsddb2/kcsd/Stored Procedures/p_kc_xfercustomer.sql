CREATE  PROCEDURE [kcsd].[p_kc_xfercustomer] AS
/* C: 客戶 */
insert	kc_customer
	(kc_cust_name, kc_id_no, kc_cust_role, kc_area_code)
select	kc_cust_name , kc_id_no, 'C', kc_area_code
from	kcsddb2.kcsd.kc_customerloan

/* D: 保人1 */
insert	kc_customer
	(kc_cust_name, kc_id_no, kc_cust_role, kc_area_code)
select	kc_cust_name1 , kc_id_no1, 'D', kc_area_code
from	kcsddb2.kcsd.kc_customerloan
where	kc_cust_name1 is not null

/* D: 保人2 */
insert	kc_customer
	(kc_cust_name, kc_id_no, kc_cust_role, kc_area_code)
select	kc_cust_name2 , kc_id_no2, 'D', kc_area_code
from	kcsddb2.kcsd.kc_customerloan
where	kc_cust_name2 is not null

/* --------------- kcsd 舊系統 --------------------------------------------- */
/* XC: 客戶 */
insert	kc_customer
	(kc_cust_name, kc_id_no, kc_cust_role, kc_area_code)
select	kc_cust_name , kc_id_no, 'XC', '01'
from	kcsddb.kcsd.dy1kc_customerloan

/* XD: 保人1 */
insert	kc_customer
	(kc_cust_name, kc_id_no, kc_cust_role, kc_area_code)
select	kc_cust_name1 , kc_id_no1, 'XD', '01'
from	kcsddb.kcsd.dy1kc_customerloan
where	kc_cust_name1 is not null

/* XD: 保人2 */
insert	kc_customer
	(kc_cust_name, kc_id_no, kc_cust_role, kc_area_code)
select	kc_cust_name2 , kc_id_no2, 'XD', '01'
from	kcsddb.kcsd.dy1kc_customerloan
where	kc_cust_name2 is not null

/* --------------- kcsd 舊系統低零利 --------------------------------------------- */
/* XC2: 低零利 */
insert	kc_customer
	(kc_cust_name, kc_id_no, kc_cust_role, kc_area_code)
select	kc_cust_name , kc_id_no, 'XC2', '01'
from	kcsddb.kcsd.dy1kc_customerloan2

/* XD2: 低零利保人1 */
insert	kc_customer
	(kc_cust_name, kc_id_no, kc_cust_role, kc_area_code)
select	kc_cust_name1 , kc_id_no1, 'XD2', '01'
from	kcsddb.kcsd.dy1kc_customerloan2
where	kc_cust_name1 is not null

/* XD2: 低零利保人2 */
insert	kc_customer
	(kc_cust_name, kc_id_no, kc_cust_role, kc_area_code)
select	kc_cust_name2 , kc_id_no2, 'XD2', '01'
from	kcsddb.kcsd.dy1kc_customerloan2
where	kc_cust_name2 is not null
