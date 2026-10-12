CREATE TABLE clean.dim_customer AS
SELECT
  customer_id,
  customer_unique_id,
  customer_zip_code_prefix AS zip_code_prefix,
  INITCAP(customer_city) AS city,
  UPPER(customer_state) AS state
FROM raw.customers;
--Zip code prefixes lost their leading zeros when loaded as numbers. Fixed in the clean layer with LPAD.
DROP TABLE clean.dim_customer;

CREATE TABLE clean.dim_customer AS
SELECT
  customer_id,
  customer_unique_id,
  LPAD(customer_zip_code_prefix::text, 5, '0') AS zip_code_prefix,
  INITCAP(customer_city) AS city,
  UPPER(customer_state) AS state
FROM raw.customers;