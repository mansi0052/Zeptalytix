import os
from sqlalchemy import create_engine, text
from urllib.parse import quote_plus
import pandas as pd

DB_PASSWORD = os.environ.get("DB_PASSWORD", "Mansi@2007")
DB_USER = os.environ.get("DB_USER", "postgres")
DB_HOST = os.environ.get("DB_HOST", "localhost")
DB_PORT = os.environ.get("DB_PORT", "5432")
DB_NAME = os.environ.get("DB_NAME", "zeptalytix")

encoded_password = quote_plus(DB_PASSWORD)
engine = create_engine(f"postgresql://{DB_USER}:{encoded_password}@{DB_HOST}:{DB_PORT}/{DB_NAME}")

query = '''
SELECT "Category", ROUND(AVG("Price")::numeric, 2) AS AvgPrice
FROM products
GROUP BY "Category"
ORDER BY AvgPrice DESC;
'''

df = pd.read_sql(text(query), engine)
print(df)