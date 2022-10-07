CREATE SCHEMA "CDM" AUTHORIZATION postgres;
CREATE SCHEMA "DDS" AUTHORIZATION postgres;
CREATE SCHEMA "QUERY" AUTHORIZATION postgres;
CREATE SCHEMA "REP" AUTHORIZATION postgres;


---Измерение product
CREATE TABLE "DDS".dm_product (
	sid serial4 NOT NULL,
	description varchar NULL,
	CONSTRAINT dm_product_pk PRIMARY KEY (sid)
);

---Измерение Sales point
CREATE TABLE "DDS".dm_sales_point (
	sid serial4 NOT NULL,
	description varchar NULL,
	CONSTRAINT dm_sales_point_pk PRIMARY KEY (sid)
);

---факт
CREATE TABLE "DDS".f_sales (
	sales_point_id int4 NOT NULL,
	product_id int4 NOT NULL,
	"date" date NOT NULL,
	sid serial4 NOT NULL,
	price numeric(10, 2) NULL,
	sales_cnt int4 NULL,
	CONSTRAINT f_sales_pk PRIMARY KEY (sid),
	CONSTRAINT f_sales_fk FOREIGN KEY (product_id) REFERENCES "DDS".dm_product(sid),
	CONSTRAINT f_sales_fk_1 FOREIGN KEY (sales_point_id) REFERENCES "DDS".dm_sales_point(sid)
);


---план продаж
CREATE TABLE "DDS".p_sales (
	sales_point_id int4 NOT NULL,
	product_id int4 NOT NULL,
	"date" date NOT NULL,
	sid serial4 NOT NULL,
	price numeric(10, 2) NULL,
	sales_cnt int4 NULL,
	CONSTRAINT p_sales_pk PRIMARY KEY (sid),
	CONSTRAINT p_sales_fk FOREIGN KEY (product_id) REFERENCES "DDS".dm_product(sid),
	CONSTRAINT p_sales_fk_1 FOREIGN KEY (sales_point_id) REFERENCES "DDS".dm_sales_point(sid)
);

---отчет
CREATE OR REPLACE VIEW "REP".v_plan_fact_month_sales
AS SELECT pfms.sales_point_id,
    pfms.product_id,
    pfms.plan_date,
    dp.description AS product,
    dsp.description AS sales_point,
    pfms.plan_revenue_amt,
    pfms.fact_revenue_amt,
    pfms.plan_comp_rec
   FROM "CDM".plan_fact_month_sales pfms
     LEFT JOIN "DDS".dm_product dp ON pfms.product_id = dp.sid
     LEFT JOIN "DDS".dm_sales_point dsp ON pfms.sales_point_id = dsp.sid;