CREATE TABLE clean.dim_product AS
SELECT
  p.product_id,
  p.product_category_name AS category_pt,
  COALESCE(t.product_category_name_english, 'unknown') AS category_en,
  p.product_weight_g AS weight_g
FROM raw.products p
LEFT JOIN raw.product_category_name_translation t
  ON p.product_category_name = t.product_category_name;
CREATE TABLE clean.dim_product AS
SELECT
  p.product_id,
  p.product_category_name AS category_pt,
  COALESCE(t.product_category_name_english, 'unknown') AS category_en,
  p.product_weight_g AS weight_g
FROM raw.products p
LEFT JOIN raw.product_category_name_translation t
  ON p.product_category_name = t.product_category_name;