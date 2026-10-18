 Insight: repeat purchase rate by category (customers placing 2+ orders, 500+ customers per category)
WITH customer_orders AS (
  SELECT c.customer_unique_id, COUNT(DISTINCT f.order_id) AS orders
  FROM clean.fact_order_items f
  JOIN clean.dim_customer c ON f.customer_id = c.customer_id
  GROUP BY c.customer_unique_id
),
customer_categories AS (
  SELECT DISTINCT c.customer_unique_id, p.category_en
  FROM clean.fact_order_items f
  JOIN clean.dim_customer c ON f.customer_id = c.customer_id
  JOIN clean.dim_product p ON f.product_id = p.product_id
)
SELECT
  cc.category_en,
  COUNT(*) AS customers,
  ROUND(100.0 * AVG(CASE WHEN co.orders >= 2 THEN 1 ELSE 0 END), 1) AS repeat_pct
FROM customer_categories cc
JOIN customer_orders co ON cc.customer_unique_id = co.customer_unique_id
GROUP BY cc.category_en
HAVING COUNT(*) >= 500
ORDER BY repeat_pct DESC
LIMIT 10;
-- Result: overall 3.1%; home_appliances 10.7%, fashion_bags_accessories 9.0%, furniture_decor 7.3%
SELECT ROUND(100.0 * AVG(CASE WHEN orders >= 2 THEN 1 ELSE 0 END), 1) AS overall_repeat_pct
FROM (
  SELECT c.customer_unique_id, COUNT(DISTINCT f.order_id) AS orders
  FROM clean.fact_order_items f
  JOIN clean.dim_customer c ON f.customer_id = c.customer_id
  GROUP BY c.customer_unique_id
) t;
-- Caution: category rates are biased upward because repeat customers appear in more categories; compare categories with each other, not with the overall rate