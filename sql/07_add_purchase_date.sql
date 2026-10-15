ALTER TABLE clean.fact_order_items ADD COLUMN purchase_date date;
UPDATE clean.fact_order_items SET purchase_date = purchased_at::date;