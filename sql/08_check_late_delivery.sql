SELECT
  COUNT(DISTINCT order_id) FILTER (WHERE delivered_at IS NOT NULL) AS delivered_orders,
  COUNT(DISTINCT order_id) FILTER (WHERE delivered_at::date > estimated_delivery_at::date) AS late_orders,
  ROUND(100.0 *
    COUNT(DISTINCT order_id) FILTER (WHERE delivered_at::date > estimated_delivery_at::date)
    / COUNT(DISTINCT order_id) FILTER (WHERE delivered_at IS NOT NULL), 2) AS late_pct
FROM clean.fact_order_items;