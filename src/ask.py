import os
import re
import sys

import pandas as pd
from dotenv import load_dotenv
from google import genai
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL

load_dotenv()

# 1. Connect to PostgreSQL as the read-only user
url = URL.create(
    "postgresql+psycopg",
    username="ai_reader",
    password=os.getenv("AI_DB_PASSWORD"),
    host="localhost",
    port=5432,
    database="olist",
)
engine = create_engine(url)
client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))
MODEL = "gemini-flash-lite-latest"


# 2. Read the table and column names automatically
def get_schema():
    query = text("""
        SELECT table_name, column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'clean'
        ORDER BY table_name, ordinal_position
    """)
    df = pd.read_sql(query, engine)
    lines = []
    for table, cols in df.groupby("table_name"):
        col_list = ", ".join(f"{c} ({t})" for c, t in zip(cols.column_name, cols.data_type))
        lines.append(f"clean.{table}: {col_list}")
    return "\n".join(lines)


# 3. Ask the AI to write SQL
def write_sql(question, schema):
    prompt = f"""You write PostgreSQL queries for a retail star schema.

Tables:
{schema}

Rules:
- Write ONE SELECT query only. Never INSERT, UPDATE, DELETE, DROP or ALTER.
- Always include the numbers that answer the question (e.g. totals), not just names.
- Round money to 2 decimal places.
- Use LIMIT 20 unless the question asks for everything.
- Return only the SQL, with no explanation and no markdown.
- "Sales" or "revenue" means SUM(price) only. Never include freight_value unless the question asks about freight or shipping.
- All money is in Brazilian reals (R$), not dollars.
- To count customers, use COUNT(DISTINCT customer_unique_id) from clean.dim_customer, not customer_id.
- Orders are counted with COUNT(DISTINCT order_id).
- "State" is ambiguous: dim_customer.state is where buyers live, dim_seller.state is where sellers are based. If the question doesn't say which, use customer state.

Question: {question}"""
    response = client.models.generate_content(model=MODEL, contents=prompt)
    sql = response.text.strip()
    sql = re.sub(r"^```(sql)?|```$", "", sql, flags=re.IGNORECASE | re.MULTILINE).strip()
    return sql


# 4. Basic safety check: only allow SELECT
def is_safe(sql):
    lowered = sql.lower()
    blocked = ["insert", "update", "delete", "drop", "alter", "truncate", "create", "grant"]
    return lowered.startswith(("select", "with")) and not any(
        re.search(rf"\b{word}\b", lowered) for word in blocked
    )


# 4b. Explain the result in plain English
def explain(question, result, sql=""):
    prompt = f"""A manager asked: {question}
This SQL was used:
{sql}
Here is the result from the database:
{result.head(20).to_string(index=False)}

Explain the answer in 2-3 short, plain-English sentences for a non-technical manager.
Use the actual numbers. Money is in Brazilian reals (R$). Note that 2016 only has data from September and 2018 only up to August, so they are partial years.
If the SQL made an assumption (for example customer state vs seller state, or which years were included), say it clearly in one sentence.
Do not mention SQL."""
    response = client.models.generate_content(model=MODEL, contents=prompt)
    return response.text.strip()


# 5. Run it
if __name__ == "__main__":
    question = " ".join(sys.argv[1:]) or "Which product category earned the most money?"
    schema = get_schema()
    sql = write_sql(question, schema)

    print("\nQUESTION:", question)
    print("\nSQL:\n", sql)

    if not is_safe(sql):
        print("\nBlocked: the query is not a safe SELECT.")
    else:
        result = pd.read_sql(text(sql), engine)
        print("\nRESULT:")
        print(result.to_string(index=False))
        print("\nANSWER:")
        print(explain(question, result))