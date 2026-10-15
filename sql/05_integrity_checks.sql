SELECT COUNT(*) AS missing_products
FROM clean.fact_order_items f
LEFT JOIN clean.dim_product p ON f.product_id = p.product_id
WHERE p.product_id IS NULL;

SELECT COUNT(*) AS missing_sellers
FROM clean.fact_order_items f
LEFT JOIN clean.dim_seller s ON f.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

SELECT COUNT(*) AS missing_customers
FROM clean.fact_order_items f
LEFT JOIN clean.dim_customer c ON f.customer_id = c.customer_id
WHERE c.customer_id IS NULL;