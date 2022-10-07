
---Sales
insert into "DDS".f_sales (date,sales_point_id,product_id,price,sales_cnt)

select sale_date as date, dsp.sid as sales_point_id, dp.sid as product_id, price, sale_cnt from
(
	select sale_date,'eldorado' as sales_point , product ,  price , sale_cnt  from dev_stg.eldorado_2022 e 
	union all
	select sale_date ,'svyaznoy' as sales_point, product ,  price , sale_cnt from dev_stg.svyaznoy_2022 s 
	union ALL
	select sale_date , 'dns' as sales_point, product , price , sale_cnt  from dev_stg.dns_2022
) as sales
left outer join "DDS".dm_product dp on sales.product = dp.description
left outer join "DDS".dm_sales_point dsp on sales.sales_point = dsp.description
;
----------------------------------------------------------------------------------
---Plan
insert into "DDS".p_sales (date,sales_point_id,product_id,price,sales_cnt)
select p.plan_date as date,dsp.sid as sales_point_id, dp.sid as product_id,  price , sale_cnt  from dev_stg.plan_2022 p
left outer join "DDS".dm_product dp on p.product = dp.description
left outer join "DDS".dm_sales_point dsp on p.sales_point = dsp.description
;

