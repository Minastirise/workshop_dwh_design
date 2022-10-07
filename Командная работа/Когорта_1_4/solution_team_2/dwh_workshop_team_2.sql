
CREATE SCHEMA dds AUTHORIZATION postgres;

CREATE TABLE dds.products (
	id serial4 NOT NULL,
	"name" varchar NOT NULL,
	date_from timestamp NULL,
	date_to timestamp NULL,
	CONSTRAINT products_pkey PRIMARY KEY (id)
);


CREATE TABLE dds.sales_points (
	id serial4 NOT NULL,
	"name" varchar NOT NULL,
	date_from timestamp NULL,
	date_to timestamp NULL,
	CONSTRAINT sales_points_pkey PRIMARY KEY (id)
);


CREATE TABLE dds.fact (
	id serial4 NOT NULL,
	product_id int4 NOT NULL,
	sales_point_id int4 NOT NULL,
	price numeric(10, 2) NULL,
	count int4 NULL,
	"date" timestamp NOT NULL,
	CONSTRAINT fact_pkey PRIMARY KEY (id),
	CONSTRAINT fact_fk FOREIGN KEY (sales_point_id) REFERENCES dds.sales_points(id),
	CONSTRAINT fact_fk_1 FOREIGN KEY (product_id) REFERENCES dds.products(id)
);


CREATE TABLE dds.plan (
	id serial4 NOT NULL,
	product_id int4 NOT NULL,
	sales_point_id int4 NOT NULL,
	price numeric(10, 2) NULL,
	count int4 NULL,
	"month" timestamp NOT NULL,
	CONSTRAINT plan_pkey PRIMARY KEY (id),
	CONSTRAINT plan_fk FOREIGN KEY (sales_point_id) REFERENCES dds.sales_points(id),
	CONSTRAINT plan_fk_1 FOREIGN KEY (product_id) REFERENCES dds.products(id)
);


CREATE SCHEMA rep AUTHORIZATION postgres;

CREATE TABLE rep.report (
	report_date timestamp NULL,
	shop_name varchar(25) NULL,
	product_name varchar(25) NULL,
	plan_revenue_amt numeric(14, 2) NULL,
	fact_revenue_amt numeric(14, 2) NULL,
	plan_comp_perc numeric(14, 2) NULL
);


INSERT INTO dds.sales_points
("name", date_from, date_to)
with cte AS (
SELECT *, 'DNS' AS sales_point FROM dev_stg.dns_2022
UNION ALL 
SELECT *, 'Эльдорадо' AS sales_point FROM dev_stg.eldorado_2022
UNION ALL 
SELECT *, 'Связной' AS sales_point FROM dev_stg.svyaznoy_2022)
SELECT DISTINCT 
sales_point,
'2022-01-01' :: date,
'2999-12-31' :: date
FROM cte;


INSERT INTO dds.products
("name", date_from, date_to)
with cte AS (
SELECT *, 'DNS' AS sales_point FROM dev_stg.dns_2022
UNION ALL 
SELECT *, 'Эльдорадо' AS sales_point FROM dev_stg.eldorado_2022
UNION ALL 
SELECT *, 'Связной' AS sales_point FROM dev_stg.svyaznoy_2022)
SELECT DISTINCT 
product,
'2022-01-01' :: date,
'2999-12-31' :: date
FROM cte;

INSERT INTO dds.fact
(product_id, sales_point_id, price, count, "date")
with cte AS (SELECT *, 'DNS' AS sales_point FROM dev_stg.dns_2022
UNION ALL 
SELECT *, 'Эльдорадо' AS sales_point FROM dev_stg.eldorado_2022
UNION ALL 
SELECT *, 'Связной' AS sales_point FROM dev_stg.svyaznoy_2022)
SELECT 
p.id,
sp.id,
c.price,
c.sale_cnt,
c.sale_date
FROM cte c
LEFT JOIN dds.products p ON c.product = p."name" 
LEFT JOIN dds.sales_points sp ON sp."name" = c.sales_point;



INSERT INTO dds.plan
(product_id, sales_point_id, price, count, "month")
SELECT 
p.id,
sp.id,
c.price,
c.sale_cnt,
(date_trunc('MONTH',to_date(concat('2022',LPAD(c.month_::text,2,'0'),'01'),'YYYYMMDD')) + INTERVAL '1 MONTH - 1 day')::date
FROM dev_stg.plan_2022 c
LEFT JOIN dds.products p ON c.product = p."name" 
LEFT JOIN dds.sales_points sp ON sp."name" = c.sales_point;


INSERT INTO rep.report
(report_date, shop_name, product_name, plan_revenue_amt, fact_revenue_amt, plan_comp_perc)
WITH cte as(
SELECT DISTINCT 
(date_trunc('MONTH',f."date")  + INTERVAL '1 MONTH - 1 day')  :: date AS report_date,
f.product_id,
f.sales_point_id,
sp."name" AS shop_name,
p."name" AS product_name,
f.price * f.count AS fact_revenue_amt
FROM dds.fact f
LEFT JOIN dds.sales_points sp ON sp.id = f.sales_point_id
LEFT JOIN dds.products p ON p.id = f.product_id)
SELECT 
p2."month" AS report_date,
c.shop_name,
c.product_name,
SUM(p2.price * p2.count),
SUM(c.fact_revenue_amt),
ROUND(SUM(c.fact_revenue_amt) / SUM(p2.price * p2.count) * 100,2)
FROM cte c
full outer JOIN dds.plan p2 ON p2.product_id = c.product_id AND p2.sales_point_id = c.sales_point_id AND c.report_date = p2."month" :: "date"
GROUP BY 1,2,3;