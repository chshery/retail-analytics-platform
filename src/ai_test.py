import os
from dotenv import load_dotenv
from google import genai

load_dotenv()
client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))

question = "Which product category earned the most money?"

prompt = f"""
You write PostgreSQL queries. The table clean.fact_order_items has columns
order_id, product_id, price, purchase_date.
The table clean.dim_product has columns product_id, category_en.
Write ONE SQL query that answers: {question}
Return only the SQL, nothing else.
"""

response = client.models.generate_content(model="gemini-flash-lite-latest", contents=prompt)
print(response.text)