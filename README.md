# Retail Analytics & Data Governance Platform

An end-to-end analytics project on the Olist Brazilian e-commerce dataset (about 100k orders, 2016-2018): raw CSVs → Python loader → PostgreSQL → star schema → Power BI dashboard.

## Tools
Python (pandas, SQLAlchemy), PostgreSQL, SQL, Power BI, Git

## Architecture
raw CSVs → `raw` schema → `clean` schema (star schema) → Power BI

**Star schema:** `fact_order_items` (112,650 rows) with `dim_customer`, `dim_product`, `dim_seller` and `dim_date`.

## Dashboard
![Dashboard](docs/images/dashboard_v1.png)

## Key findings
- Total sales: 13.59M BRL across 99,441 orders.
- About 96.7% of orders contain a single item.
- Sellers are concentrated in São Paulo state, which accounts for about 64% of sales.
- Only about 3% of orders come from repeat customers.
- Health & beauty is the top-selling category (about 1.26M BRL).

## Business insights

| Question | Finding | Recommendation |
|---|---|---|
| Do late deliveries hurt customer satisfaction? | Late orders average 2.27 stars vs 4.29 for on-time orders. 62.4% of late orders get a 1-2 star review, vs 9.3% of on-time orders. Late orders are about 7% of deliveries but produce about a third of all bad reviews. | Improve delivery estimates and carrier performance. If late orders were reviewed like on-time ones, there would be roughly 3,400 fewer bad reviews (illustrative estimate). |
| How often do customers return? | Only about 3% of orders come from repeat customers. | Test loyalty or re-engagement offers. |
| How big are baskets? | 96.7% of orders contain a single item. | Try bundles or "customers also bought" suggestions. |
| Where are sellers concentrated? | About 64% of seller sales come from São Paulo state. | Recruit sellers in other regions to reduce dependence on one area. |
| Which categories lose most to shipping? | Freight adds 16.6% to item prices on average, but 29.1% for electronics (about 1.75 times the average). Cheap items (electronics, food, telephony) pay a high share because prices are low; bulky furniture pays the most per delivery (about R$40 for office furniture). | Use free-shipping thresholds or bundles for cheap items; place sellers or stock closer to customers for bulky items. |

**Note:** these are insights from a public 2016-2018 dataset. They show strong associations, not proven causes, and the money estimates are illustrative.
## Data quality issues found
- 8 orders marked "delivered" have no delivery date.
- 775 orders have no items (mostly unavailable or canceled).
- 610 products have no category.
- Zip codes lost their leading zeros on import (fixed in the clean layer).
- The dataset is incomplete at the end of 2018, so the sales drop in the last month is not a real trend.

See `docs/data_quality_log.md` for details.

## Project status
- [x] Raw load, clean layer, star schema, integrity checks
- [x] Power BI dashboard v1
- [ ] Data dictionary, lineage and governance documentation
- [ ] Natural language to SQL assistant