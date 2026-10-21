import pandas as pd
from sqlalchemy import text
from ask import engine, get_schema, write_sql, is_safe

# question -> the correct top value we already know
tests = [
    ("Which product category earned the most money?", "health_beauty"),
    ("Which seller state has the highest sales?", "SP"),
    ("What was total sales in 2018?", "7386050"),
    ("What was total sales in 2017?", "6155806"),
    ("How many orders are there in total?", "98666"),
    ("How many unique customers placed orders?", "95420"),
    ("Which category has the second highest sales?", "watches_gifts"),
    ("What is the average item price?", "120.65"),
    ("How many sellers are there?", "3095"),
    ("Which month had the highest sales?", "2017-11"),
]

schema = get_schema()
passed = 0
for question, expected in tests:
    sql = write_sql(question, schema)
    try:
        if not is_safe(sql):
            raise ValueError("blocked")
        result = pd.read_sql(text(sql), engine)
        got = result.to_string(index=False).replace(",", "")
        ok = expected.lower() in got.lower()
    except Exception as e:
        got, ok = f"ERROR: {e}", False
    passed += ok
    print(f"{'PASS' if ok else 'FAIL'} | {question}")
    if not ok:
        print("   SQL:", sql.replace(chr(10), " "))
        print("   GOT:", got[:200])

print(f"\nScore: {passed}/{len(tests)}")