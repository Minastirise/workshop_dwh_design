----Mart


insert into "CDM".plan_fact_month_sales 
(sales_point_id, product_id, plan_date, plan_revenue_amt, fact_revenue_amt, plan_comp_rec)

select sales_point_id, product_id, date as plan_date, sum(plan_revenue_amt) as plan_revenue_amt, sum(fact_revenue_amt) as fact_revenue_amt,
	( sum( fact_revenue_amt) * 100 )/ sum(plan_revenue_amt) as plan_comp_rec
	
	from 
(
select sales_point_id, product_id, ps."date" as date, sum( price * sales_cnt ) AS plan_revenue_amt, 0 as fact_revenue_amt
from "DDS".p_sales ps 
GROUP BY 
sales_point_id, product_id, date

union ALL
SELECT sales_point_id, product_id, (date_trunc('month',"date") + interval '1 month' - interval '1 day')::date as date, 0 as plan_revenue_amt, sum( price * sales_cnt ) AS fact_revenue_amt
FROM "DDS".f_sales 
GROUP BY 
sales_point_id, product_id, date
) as a

group by sales_point_id, product_id, date
order by 3,1,2;

