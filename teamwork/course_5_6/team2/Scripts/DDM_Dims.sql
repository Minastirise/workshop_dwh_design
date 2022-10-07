---product
insert into "DDS".dm_sales_point (description) SELECT DISTINCT sales_point FROM dev_stg.plan_2022 p;

---sales point
insert into "DDS".dm_sales_point (description) 
( select distinct a.sales_point  from dev_stg.plan_2022 a    

)





