# Data Dictionary: clean schema

**Classification key:** Public / Internal / Confidential (identifiers or location data that could single out a person when combined). The dataset is anonymised, but each field is classified as it would be in a real business.

## clean.dim_customer

**Purpose:** one row per customer record, used to analyse who buys and where they are.
**Grain:** one row per `customer_id`. Note that `customer_id` is created per order, so one person can have several rows.
**Primary key:** `customer_id`
**Source:** `raw.customers`
**Row count:** 99,441 (96,096 distinct people)

| Column | Type | Description | Source and transformation | Classification |
|---|---|---|---|---|
| customer_id | text | Identifier for a customer on one order. A returning customer gets a new one each order. | raw.customers.customer_id, unchanged | Confidential |
| customer_unique_id | text | Identifier for the actual person across all their orders. Use this to count customers or repeat buyers. | raw.customers.customer_unique_id, unchanged | Confidential |
| zip_code_prefix | text | First 5 digits of the customer's Brazilian postcode. | raw.customers.customer_zip_code_prefix, converted to text and left-padded with zeros to 5 characters (the leading zero had been lost on import) | Confidential |
| city | text | Customer's city, in title case. Has no accents, as in the source. | raw.customers.customer_city, INITCAP | Internal |
| state | text | Two-letter Brazilian state code, uppercase. | raw.customers.customer_state, UPPER | Internal |

**Known issues:** the `customer_id` / `customer_unique_id` distinction is easy to misuse, and counting `customer_id` overstates customers by about 3,300.

## clean.dim_seller

**Purpose:** one row per seller on the marketplace, used to analyse where sales come from and how concentrated they are.
**Grain:** one row per `seller_id`.
**Primary key:** `seller_id`
**Source:** `raw.sellers`
**Row count:** 3,095

| Column | Type | Description | Source and transformation | Classification |
|---|---|---|---|---|
| seller_id | text | Unique identifier for a seller. The same seller keeps one ID across all their sales. | raw.sellers.seller_id, unchanged | Internal |
| zip_code_prefix | text | First 5 digits of the seller's Brazilian postcode. | raw.sellers.seller_zip_code_prefix, converted to text and left-padded with zeros to 5 characters | Internal |
| city | text | Seller's city, in title case. Has no accents, as in the source. | raw.sellers.seller_city, INITCAP | Internal |
| state | text | Two-letter Brazilian state code, uppercase. | raw.sellers.seller_state, UPPER | Internal |

**Classification note:** sellers are businesses, so their location data is classed as Internal. Customer location is Confidential because customers are consumers, and location combined with other fields could identify a person. Review this if the data ever included street addresses, or if a seller is an individual trader.

**Known issues:** none found. City names have no accents, inherited from the source.

## clean.dim_product

**Purpose:** one row per product, used to analyse sales by product category.
**Grain:** one row per `product_id`.
**Primary key:** `product_id`
**Source:** `raw.products`, joined to `raw.product_category_name_translation`
**Row count:** 32,951

| Column | Type | Description | Source and transformation | Classification |
|---|---|---|---|---|
| product_id | text | Unique identifier for a product. | raw.products.product_id, unchanged | Internal |
| category_pt | text | Product category in Portuguese, as recorded in the source. NULL for products with no category. | raw.products.product_category_name, renamed | Internal |
| category_en | text | Product category in English. Products with no category are labelled `unknown`. | Looked up in the translation table with a LEFT JOIN. Two categories missing from that table (`pc_gamer` and `portateis_cozinha_e_preparadores_de_alimentos`) were mapped manually. Remaining gaps filled with `unknown` using COALESCE | Internal |
| weight_g | double precision | Product weight in grams. | raw.products.product_weight_g, renamed | Internal |

**Known issues:**
- 610 products (about 1.9%) have no category in the source and are labelled `unknown`.
- 13 products had categories missing from the translation table and were mapped manually.
- `weight_g` has 2 missing values.

## clean.dim_date

**Purpose:** a calendar table with one row per day, used to group sales by month, quarter, year or weekday.
**Grain:** one row per calendar date.
**Primary key:** `date_key`
**Source:** generated in SQL with `generate_series`, not loaded from the raw data.
**Row count:** 1,096 (1 Jan 2016 to 31 Dec 2018)

| Column | Type | Description | Source and transformation | Classification |
|---|---|---|---|---|
| date_key | date | The calendar date. Joins to `fact_order_items.purchase_date`. | Generated | Public |
| year | integer | Calendar year. | EXTRACT from date_key | Public |
| quarter | integer | Calendar quarter, 1 to 4. | EXTRACT from date_key | Public |
| month | integer | Month number, 1 to 12. | EXTRACT from date_key | Public |
| month_name | text | Month name, for example "March". | TO_CHAR, trimmed | Public |
| weekday_number | integer | ISO weekday, 1 (Monday) to 7 (Sunday). | EXTRACT ISODOW from date_key | Public |
| weekday_name | text | Weekday name, for example "Monday". | TO_CHAR, trimmed | Public |
| year_month | text | Year and month as `YYYY-MM`, used for time charts. | Added later with ALTER TABLE and UPDATE | Public |

**Known issues:** the range only covers 2016 to 2018, which matches the orders data. Orders outside it would not find a matching date.

## clean.fact_order_items

**Purpose:** the central fact table of the star schema. It holds the measurable numbers (price, freight) and dates for every item sold, and links to all four dimensions.
**Grain:** one row per item in an order. If someone buys 3 units of the same product, that is 3 rows, because the source has no quantity column.
**Primary key:** (`order_id`, `order_item_id`)
**Foreign keys:** `product_id` to `dim_product`, `seller_id` to `dim_seller`, `customer_id` to `dim_customer`, `purchase_date` to `dim_date`
**Source:** `raw.order_items` joined to `raw.orders` on `order_id`
**Row count:** 112,650

| Column | Type | Description | Source and transformation | Classification |
|---|---|---|---|---|
| order_id | text | Identifier of the order this item belongs to. | raw.order_items.order_id, unchanged | Internal |
| order_item_id | bigint | Position of the item within its order (1, 2, 3...). Together with `order_id` it identifies one row. | raw.order_items.order_item_id, unchanged | Internal |
| product_id | text | The product sold. | raw.order_items.product_id, unchanged | Internal |
| seller_id | text | The seller who sold the item. | raw.order_items.seller_id, unchanged | Internal |
| customer_id | text | The customer record for this order. Links to `dim_customer`. Use `customer_unique_id` there to count people. | raw.orders.customer_id, via the join | Confidential |
| order_status | text | Order status, such as delivered, shipped or canceled. | raw.orders.order_status, unchanged | Internal |
| purchased_at | timestamp | When the order was placed. | raw.orders.order_purchase_timestamp, cast to timestamp | Internal |
| delivered_at | timestamp | When the customer received the order. NULL if not yet delivered. | raw.orders.order_delivered_customer_date, cast to timestamp | Internal |
| estimated_delivery_at | timestamp | The delivery date promised to the customer. | raw.orders.order_estimated_delivery_date, cast to timestamp | Internal |
| price | numeric | Price of the item in Brazilian reais, excluding freight. | raw.order_items.price, rounded to 2 decimals as an exact number | Internal |
| freight_value | numeric | Shipping cost allocated to the item, in Brazilian reais. | raw.order_items.freight_value, rounded to 2 decimals as an exact number | Internal |
| purchase_date | date | The date part of `purchased_at`. Joins to `dim_date`. | Added later with ALTER TABLE: purchased_at cast to date | Internal |

**Known issues:**
- 8 orders are marked "delivered" but have no delivery date.
- 775 orders in the raw data have no items, so they do not appear in this table (mostly unavailable or canceled).
- There is no quantity column, so row counts are units, not distinct products.
- A late delivery is defined by comparing dates only (`delivered_at` after `estimated_delivery_at`), ignoring the time of day.