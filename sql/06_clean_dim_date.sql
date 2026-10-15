CREATE TABLE clean.dim_date AS
SELECT
  d::date AS date_key,
  EXTRACT(YEAR FROM d)::int AS year,
  EXTRACT(QUARTER FROM d)::int AS quarter,
  EXTRACT(MONTH FROM d)::int AS month,
  TRIM(TO_CHAR(d, 'Month')) AS month_name,
  EXTRACT(ISODOW FROM d)::int AS weekday_number,
  TRIM(TO_CHAR(d, 'Day')) AS weekday_name
FROM generate_series('2016-01-01'::date, '2018-12-31'::date, interval '1 day') AS d;