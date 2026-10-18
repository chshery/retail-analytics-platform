-- Insight: late deliveries vs review scores (one review per order, latest kept)
-- Result: late 2.27 avg, 62.4% bad reviews; on time 4.29 avg, 9.3% bad reviews
WITH latest_review AS (
  SELECT order_id, review_score
  FROM (
    SELECT
      order_id,
      review_score,
      ROW_NUMBER() OVER (
        PARTITION BY order_id
        ORDER BY review_answer_timestamp DESC
      ) AS rn
    FROM raw.order_reviews
  ) t
  WHERE rn = 1
),
delivered_orders AS (
  SELECT DISTINCT order_id, delivered_at, estimated_delivery_at
  FROM clean.fact_order_items
  WHERE delivered_at IS NOT NULL
)
SELECT
  CASE WHEN o.delivered_at::date > o.estimated_delivery_at::date
       THEN 'late' ELSE 'on time' END AS delivery,
  COUNT(*) AS orders,
  ROUND(AVG(r.review_score), 2) AS avg_score,
  ROUND(100.0 * AVG(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END), 1) AS pct_bad_reviews
FROM delivered_orders o
JOIN latest_review r ON o.order_id = r.order_id
GROUP BY 1;