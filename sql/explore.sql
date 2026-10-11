-- Exploration queries on the raw Olist data
-- Author: <your name>

-- 1. How many customer records are there?
SELECT COUNT(*)
FROM raw.customers;

-- 2. How many real people? (customer_id changes per order,
--    customer_unique_id identifies the person)
SELECT COUNT(DISTINCT customer_unique_id)
FROM raw.customers;

-- 3. How many orders per status?
SELECT order_status, COUNT(*)
FROM raw.orders
GROUP BY order_status
ORDER BY COUNT(*) DESC;

-- 4. Which statuses have no delivery date?
SELECT order_status, COUNT(*)
FROM raw.orders
WHERE order_delivered_customer_date IS NULL
GROUP BY order_status
ORDER BY COUNT(*) DESC;

-- 5. Data quality: orders marked delivered but with no delivery date
SELECT order_id, order_status,
       order_purchase_timestamp,
       order_delivered_carrier_date,
       order_delivered_customer_date,
       order_estimated_delivery_date
FROM raw.orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NULL;

-- 6. Of those, how many have a carrier date? (expected: 8 and 7)
SELECT
  COUNT(*) AS total,
  COUNT(order_delivered_carrier_date) AS has_carrier_date
FROM raw.orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NULL;

-- 7. First JOIN: each item with its product category
SELECT order_items.order_id, order_items.price, products.product_category_name
FROM raw.order_items
JOIN raw.products
  ON order_items.product_id = products.product_id
LIMIT 10;

-- 8. Total sales per product category (top 10)
SELECT products.product_category_name, SUM(order_items.price) AS total_sales
FROM raw.order_items
JOIN raw.products
  ON order_items.product_id = products.product_id
GROUP BY products.product_category_name
ORDER BY total_sales DESC
LIMIT 10;

-- 9. Basket size: how many orders have 1, 2, 3... items?
SELECT items_in_order, COUNT(*) AS number_of_orders
FROM (
  SELECT order_id, COUNT(*) AS items_in_order
  FROM raw.order_items
  GROUP BY order_id
) AS order_sizes
GROUP BY items_in_order
ORDER BY items_in_order;

-- 10. Total sales per seller state
SELECT sellers.seller_state, SUM(order_items.price) AS total_sales
FROM raw.order_items
JOIN raw.sellers
  ON order_items.seller_id = sellers.seller_id
GROUP BY sellers.seller_state
ORDER BY total_sales DESC
LIMIT 10;