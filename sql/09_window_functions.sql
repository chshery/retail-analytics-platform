-- Window function practice on the clean star schema

-- 1. Rank categories by total sales
SELECT
  p.category_en,
  ROUND(SUM(f.price), 0) AS total_sales,
  RANK() OVER (ORDER BY SUM(f.price) DESC) AS sales_rank
FROM clean.fact_order_items f
JOIN clean.dim_product p ON f.product_id = p.product_id
GROUP BY p.category_en
ORDER BY sales_rank
LIMIT 10;

-- 2. Top 3 categories per year (PARTITION BY restarts the ranking in each year)
SELECT year, category_en, total_sales, sales_rank
FROM (
  SELECT
    d.year,
    p.category_en,
    ROUND(SUM(f.price), 0) AS total_sales,
    RANK() OVER (PARTITION BY d.year ORDER BY SUM(f.price) DESC) AS sales_rank
  FROM clean.fact_order_items f
  JOIN clean.dim_product p ON f.product_id = p.product_id
  JOIN clean.dim_date d ON f.purchase_date = d.date_key
  GROUP BY d.year, p.category_en
) ranked
WHERE sales_rank <= 3
ORDER BY year, sales_rank;

-- 3. ROW_NUMBER vs RANK vs DENSE_RANK on tied prices
SELECT
  f.order_id,
  f.price,
  ROW_NUMBER() OVER (ORDER BY f.price DESC) AS row_num,
  RANK()       OVER (ORDER BY f.price DESC) AS rnk,
  DENSE_RANK() OVER (ORDER BY f.price DESC) AS dense_rnk
FROM clean.fact_order_items f
ORDER BY f.price DESC
LIMIT 10;

-- 4. Month-over-month change with LAG
-- LAG ignores missing months, and tiny early months and an incomplete 2018-09 distort the percentages
SELECT
  year_month,
  monthly_sales,
  LAG(monthly_sales) OVER (ORDER BY year_month) AS previous_month,
  ROUND(100.0 * (monthly_sales - LAG(monthly_sales) OVER (ORDER BY year_month))
        / LAG(monthly_sales) OVER (ORDER BY year_month), 1) AS pct_change
FROM (
  SELECT d.year_month, ROUND(SUM(f.price), 0) AS monthly_sales
  FROM clean.fact_order_items f
  JOIN clean.dim_date d ON f.purchase_date = d.date_key
  GROUP BY d.year_month
) monthly
ORDER BY year_month;

-- 5. Running total of sales (last row should be about 13.59 million)
SELECT
  year_month,
  monthly_sales,
  SUM(monthly_sales) OVER (ORDER BY year_month) AS running_total
FROM (
  SELECT d.year_month, ROUND(SUM(f.price), 0) AS monthly_sales
  FROM clean.fact_order_items f
  JOIN clean.dim_date d ON f.purchase_date = d.date_key
  GROUP BY d.year_month
) monthly
ORDER BY year_month;