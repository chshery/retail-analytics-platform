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