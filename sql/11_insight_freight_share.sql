-- Insight: freight as a share of price by category (categories with 500+ items)
-- Result: overall 16.6%; electronics 29.1%, furniture_living_room 26.1%, office_furniture 25.0%
SELECT
  p.category_en,
  COUNT(*) AS items_sold,
  ROUND(AVG(f.price), 2) AS avg_price,
  ROUND(AVG(f.freight_value), 2) AS avg_freight,
  ROUND(100.0 * SUM(f.freight_value) / SUM(f.price), 1) AS freight_pct_of_price
FROM clean.fact_order_items f
JOIN clean.dim_product p ON f.product_id = p.product_id
GROUP BY p.category_en
HAVING COUNT(*) >= 500
ORDER BY freight_pct_of_price DESC
LIMIT 10;

SELECT ROUND(100.0 * SUM(freight_value) / SUM(price), 1) AS overall_freight_pct
FROM clean.fact_order_items;