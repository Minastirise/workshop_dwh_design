TRUNCATE TABLE dev_stg.plan_2022;
TRUNCATE TABLE dev_stg.svyaznoy_2022;
TRUNCATE TABLE dev_stg.eldorado_2022;
TRUNCATE TABLE dev_stg.dns_2022;

SET datestyle TO iso, dmy;

COPY dev_stg.plan_2022 FROM '/opt/input_data/plan/plan_2022.csv' DELIMITER ';' CSV header;

COPY dev_stg.svyaznoy_2022 FROM '/opt/input_data/fact/svyaznoy_2022.csv' DELIMITER ';' CSV header;

COPY dev_stg.eldorado_2022 FROM '/opt/input_data/fact/eldorado_2022.csv' DELIMITER ';' CSV header;

COPY dev_stg.dns_2022 FROM '/opt/input_data/fact/dns_2022.csv' DELIMITER ';' CSV header;
