# Data Quality Log

Issues found while exploring and cleaning the Olist data. The raw layer is never changed; fixes and flags are applied in the clean layer.

| # | Table | Issue | Impact | Action |
|---|---|---|---|---|
| 1 | orders | 8 orders are marked "delivered" but have no delivery date. 7 have a carrier date and 1 doesn't. | Status and dates contradict each other | Kept as is; excluded from delivery-time measures |
| 2 | orders | 6 canceled orders have a delivery date. | Possibly cancelled after delivery (returns) | Needs checking later |
| 3 | orders / order_items | 775 orders have no items. 767 are unavailable or canceled, 5 are created, and 3 (2 invoiced, 1 shipped) have a status that contradicts having no items. | These orders don't appear in the fact table | Kept in raw; 3 contradictory orders flagged |
| 4 | order_items | No quantity column. Several units of one product appear as repeated rows. | Row counts are units, not distinct products | Documented; use COUNT(DISTINCT product_id) for product counts |
| 5 | customers | `customer_id` is created per order; `customer_unique_id` identifies the person. | Counting customer_id overstates customers by about 3,300 | Use customer_unique_id to count customers |
| 6 | customers / sellers | Zip code prefixes lost their leading zeros when loaded as numbers. | Codes like 01151 appeared as 1151 | Fixed in clean layer with LPAD to 5 digits |
| 7 | products | 610 products have no category. | Their sales can't be grouped by category | Labelled "unknown" |
| 8 | products / translation | 13 products had categories missing from the translation table (`pc_gamer`, `portateis_cozinha_e_preparadores_de_alimentos`). | Would have shown as "unknown" | Mapped manually in the clean layer |
| 9 | products | 2 products have no weight. | Minor | Left as NULL |
| 10 | order_items | Prices were loaded as floating-point numbers, causing tiny rounding noise. | Totals like 1258681.3400000182 | Stored as exact NUMERIC rounded to 2 decimals |
| 11 | order_reviews | 547 orders have more than one review. | Would double-count orders in review analysis | Latest review per order kept, using ROW_NUMBER |
| 12 | whole dataset | Data is incomplete at the start (2016) and end (2018-09), and November 2016 has no orders. | Month-over-month changes there are misleading | Only Jan 2017 to Aug 2018 used for trends |