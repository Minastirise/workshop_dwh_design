--  
-- Наименьшие продажи были в августе в Эльдорадо, продукт: яндекс станция mini - 12% от плана 
-- 2022-08-31	eldorado	яндекс станция mini	3671541000.00	446635980.00	12
--

create schema if not exists dds;
create schema if not exists cdm;

drop table if exists dds.sales_points cascade;

drop table if exists dds.product cascade;

drop table if exists dds.sales cascade;

drop table if exists dds.plan cascade;

drop table if exists dds.sales_dates cascade;

drop table if exists cdm.plan_res cascade;

create table cdm.plan_res (
	id serial primary key,
Plan_date date not null,
Sales_point Varchar(50),
Product_name Varchar(50),
Plan_revenue_amt decimal(14,2),
Fact_revenue_amt decimal(14,2),
Plan_comp_perc integer
);


create table dds.sales_points (
	id serial primary key,
sale_point_name text not null
);

create table dds.product (
	id serial primary key,
product_name text not null
);

create table dds.sales_dates (
	id serial primary key,
sale_date date not null
);

create table dds.sales (
	product_id bigint not null,
sales_point_id bigint not null,
sale_date_id bigint not null,
price decimal(10,
2),
sale_cnt bigint ,
primary key( product_id,
sales_point_id,
sale_date_id)
);

alter table dds.sales 
	add constraint product_id_fkey foreign key (product_id) references dds.product (id),
add constraint sales_point_id_fkey foreign key (sales_point_id) references dds.sales_points (id),
add constraint sale_date_id_fkey foreign key (sale_date_id) references dds.sales_dates (id)
;
----------------------------------------------------- 
insert
	into
	dds.sales_dates (sale_date)
with rt as (
	select
		sale_date
	from
		dev_stg.dns_2022
union
	select
		sale_date
	from
		dev_stg.eldorado_2022
union
	select
		sale_date
	from
		dev_stg.svyaznoy_2022

)
select
	distinct sale_date
from
	rt
order by
	1

;
----------------------------------------------------- 
insert
	into
	dds.product (product_name)
with sd as (
	select
		product
	from
		dev_stg.dns_2022
union
	select
		product
	from
		dev_stg.eldorado_2022
union
	select
		product
	from
		dev_stg.svyaznoy_2022

)
select
	distinct product
from
	sd
order by
	1
;
----------------------------------------------------- 
insert
	into
	dds.sales_points (sale_point_name)
select
	distinct sales_point
from
	dev_stg.plan_2022
order by
	1
;
----------------------------------------------------- 
insert
	into
	dds.sales (product_id,
	sales_point_id ,
	sale_date_id ,
	price,
	sale_cnt )
with sales_on_point as (
	select
		1 as sale_point_id,
		sale_date,
		product,
		price,
		sale_cnt
	from
		dev_stg.dns_2022
union
	select
		2 as sale_point_id,
		sale_date,
		product,
		price,
		sale_cnt
	from
		dev_stg.eldorado_2022
union
	select
		3 as sale_point_id,
		sale_date,
		product,
		price,
		sale_cnt
	from
		dev_stg.svyaznoy_2022 
),
	product_tbl as (
	select
		id,
		product_name
	from
		dds.product),
	sales_dates_tbl as (
	select
		id,
		sale_date
	from
		dds.sales_dates) 
select
	product_tbl.id,
	sales_on_point.sale_point_id,
	sales_dates_tbl.id,
	sales_on_point.price,
	sales_on_point.sale_cnt
from
	sales_on_point
join product_tbl on
	sales_on_point.product = product_tbl.product_name
join sales_dates_tbl on
	sales_on_point.sale_date = sales_dates_tbl.sale_date
;	

-----------------------------------------------------

INSERT INTO cdm.plan_res (plan_date, sales_point, product_name, plan_revenue_amt, fact_revenue_amt, plan_comp_perc) 
with 
sls_plans as (select	sls.plan_date  ,	sls.sales_point ,	sls.product,	sum( sls.price * sls.sale_cnt)  as plan_revenu
	from dev_stg.plan_2022 sls
	group by
		sls.plan_date ,
		sls.sales_point ,
		sls.product),
sls_fact as (
	select
		(date_trunc('month', sd.sale_date ) + interval '1 month' - interval '1 day' )::date as sale_date ,
		sp.sale_point_name,
		p.product_name,
		sum( sls.price * sls.sale_cnt)  as fact_revenu
	from
		dds.sales sls
	join dds.sales_dates sd on
		sls.sale_date_id = sd.id
	join dds.sales_points sp on
		sls.sales_point_id = sp.id
	join dds.product p on
		sls.product_id = p.id
	group by
		(date_trunc('month', sd.sale_date ) + interval '1 month' - interval '1 day' )::date ,
		sp.sale_point_name,
		p.product_name
)
select
	sd.plan_date as plan_date ,
	sd.sales_point as sales_point ,
	sd.product as product_name ,	
     sd.plan_revenu as plan_revenue_amt ,
	 coalesce(sls2.fact_revenu, 0) as fact_revenue_amt , 
	(( coalesce(sls2.fact_revenu, 0) /sd.plan_revenu)  * 100)::integer as plan_comp_perc
from
	sls_fact sls2
	FULL OUTER  join sls_plans sd on
	sls2.sale_date  = sd.plan_date
	and sd.product = sls2.product_name
	and sd.sales_point = sls2.sale_point_name
group by
	sd.plan_date ,
	sd.sales_point ,
	sd.product,
     sd.plan_revenu  ,
	 coalesce(sls2.fact_revenu, 0)   
order by 1,2,3	
;