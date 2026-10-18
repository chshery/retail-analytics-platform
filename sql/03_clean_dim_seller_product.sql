DROP TABLE IF EXISTS clean.dim_product;

CREATE TABLE clean.dim_product AS
SELECT
  p.product_id,
  p.product_category_name AS category_pt,
  COALESCE(
    t.product_category_name_english,
    CASE p.product_category_name
      WHEN 'pc_gamer' THEN 'pc_gamer'
      WHEN 'portateis_cozinha_e_preparadores_de_alimentos'
        THEN 'portable_kitchen_food_preparers'
    END,
    'unknown'
  ) AS category_en,
  p.product_weight_g AS weight_g
FROM raw.products p
LEFT JOIN raw.product_category_name_translation t
  ON p.product_category_name = t.product_category_name;