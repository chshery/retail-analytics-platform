SELECT
  p.category_en,
  f.order_id,
  f.price,
  RANK() OVER (PARTITION BY p.category_en ORDER BY f.price DESC) AS price_rank
FROM clean.fact_order_items f
JOIN clean.dim_product p ON f.product_id = p.product_id
ORDER BY price_rank
LIMIT 10;