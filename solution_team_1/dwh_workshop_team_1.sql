/* -- create schemas -- */
CREATE SCHEMA test_cdm;
CREATE SCHEMA test_reporting;

/* -- create tables -- */
--cdm table
--
create table test_cdm.cdm (
	"date" date, 
	sales_point varchar (50),
	product varchar (50),
	price decimal(10,2),
	sale_cnt integer,
	is_plan boolean default false
);
--reporting table
--
create table test_reporting.monthly_sales_report (
	report_date int, 
	shop_name varchar (50),
	product_name varchar (50),
	plan_revenue_amt float,
	fact_revenue_amt float,
	plan_comp_perc float
);


/* -- insert data -- */
-- CDM layer
--
INSERT INTO test_cdm.cdm
SELECT TO_DATE('2022' || '-' || LPAD(month_::text, 2, '0') ||'-'|| '01', 'YYYY-MM-DD') AS date,
       sales_point,
       product,
       price,
       sale_cnt,
       TRUE AS is_plan
FROM test.dev_stg.plan_2022
UNION
SELECT sale_date AS date,
       'DNS' AS sales_point,
       product,
       price,
       sale_cnt,
       FALSE AS is_plan
FROM test.dev_stg.dns_2022
UNION
SELECT sale_date AS date,
       'Эльдорадо' AS sales_point,
       product,
       price,
       sale_cnt,
       FALSE AS is_plan
FROM test.dev_stg.eldorado_2022
UNION
SELECT sale_date AS date,
       'Связной' AS sales_point,
       product,
       price,
       sale_cnt,
       FALSE AS is_plan
FROM test.dev_stg.svyaznoy_2022;
-- reporting layer
--
INSERT INTO test_reporting.monthly_sales_report WITH PLAN AS
  (SELECT EXTRACT (MONTH
                   FROM "date") AS "month",
                  sales_point,
                  product,
                  price * sale_cnt AS plan_revenue_amt
   FROM test_cdm.cdm c
   WHERE is_plan = TRUE ), fact AS
  (SELECT EXTRACT (MONTH
                   FROM "date") AS "month",
                  sales_point,
                  product,
                  sum(price * sale_cnt) AS fact_revenue_amt
   FROM test_cdm.cdm AS c
   WHERE is_plan = FALSE
   GROUP BY "month",
            sales_point,
            product)
SELECT f.*,
       p.plan_revenue_amt,
       f.fact_revenue_amt/p.plan_revenue_amt AS plan_comp_perc
FROM fact AS f
LEFT JOIN PLAN AS p ON f."month" = p."month"
AND f.sales_point = p.sales_point
AND f.product = p.product;

