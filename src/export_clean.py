import os
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.engine import URL

load_dotenv()

url = URL.create(
    "postgresql+psycopg",
    username="postgres",
    password=os.getenv("DB_PASSWORD"),
    host="localhost",
    port=5432,
    database="olist",
)
engine = create_engine(url)

out_dir = Path("data/export")
out_dir.mkdir(parents=True, exist_ok=True)

tables = ["dim_customer", "dim_seller", "dim_product", "dim_date", "fact_order_items"]

for table in tables:
    df = pd.read_sql(f"SELECT * FROM clean.{table}", engine)
    df.to_csv(out_dir / f"{table}.csv", index=False, date_format="%Y-%m-%d %H:%M:%S")
    print(f"Exported {table}: {len(df)} rows")