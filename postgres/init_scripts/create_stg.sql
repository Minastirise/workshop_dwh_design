create schema dev_stg;

create table dev_stg.plan_2022 (
Plan_date date,
Sales_point	varchar(50),
Product varchar(50),
Price decimal(10,2),
Sale_cnt int
);

create table dev_stg.svyaznoy_2022 (
Sale_date date,
Product varchar(50),
Price decimal(10,2),
Sale_cnt integer
);

create table dev_stg.eldorado_2022 (
Sale_date date,
Product varchar(50),
Price decimal(10,2),
Sale_cnt integer
);

create table dev_stg.dns_2022 (
Sale_date date,
Product varchar(50),
Price decimal(10,2),
Sale_cnt integer
);
