import os
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

with engine.connect() as conn:
    print(conn.execute(text("SELECT version();")).scalar())