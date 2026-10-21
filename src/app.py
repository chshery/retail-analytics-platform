import pandas as pd
import streamlit as st
from sqlalchemy import text
from ask import engine, get_schema, write_sql, is_safe, explain

st.set_page_config(page_title="Retail Data Assistant", page_icon="📊")
st.title("📊 Retail Data Assistant")
st.caption("Ask a question about the Olist retail data in plain English.")

question = st.text_input("Your question", placeholder="e.g. What were total sales each year?")

if question:
    with st.spinner("Thinking..."):
        sql = write_sql(question, get_schema())
    with st.expander("See the SQL"):
        st.code(sql, language="sql")

    if not is_safe(sql):
        st.error("Blocked: only read-only SELECT queries are allowed.")
    else:
        result = pd.read_sql(text(sql), engine)
        st.dataframe(result, use_container_width=True)
        if result.shape[1] == 2 and len(result) > 1 and pd.api.types.is_numeric_dtype(result.iloc[:, 1]):
            st.bar_chart(result.set_index(result.columns[0]))
        st.subheader("Answer")
        st.write(explain(question, result, sql))