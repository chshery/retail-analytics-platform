import os
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text
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

with engine.begin() as conn:
    conn.execute(text("CREATE SCHEMA IF NOT EXISTS raw;"))

for csv_path in Path("data/raw").glob("*.csv"):
    table = csv_path.stem.replace("olist_", "").replace("_dataset", "")
    df = pd.read_csv(csv_path)
    df.to_sql(table, engine, schema="raw", if_exists="replace", index=False)
    print(f"Loaded {table}: {len(df)} rows")