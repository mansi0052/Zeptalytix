import pandas as pd
import os
from sqlalchemy import create_engine
from urllib.parse import quote_plus

def load_to_postgres():
    print("Loading cleaned data...")
    df = pd.read_csv("data/cleaned_products.csv", parse_dates=["Date"])

    # Reads from environment variables if set (Docker), otherwise falls back to local defaults
    DB_PASSWORD = os.environ.get("DB_PASSWORD", "Mansi@2007")
    DB_USER = os.environ.get("DB_USER", "postgres")
    DB_HOST = os.environ.get("DB_HOST", "localhost")
    DB_PORT = os.environ.get("DB_PORT", "5432")
    DB_NAME = os.environ.get("DB_NAME", "zeptalytix")

    encoded_password = quote_plus(DB_PASSWORD)
    connection_string = f"postgresql://{DB_USER}:{encoded_password}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
    engine = create_engine(connection_string)

    print("Writing to PostgreSQL...")
    df.to_sql("products", engine, if_exists="replace", index=False)

    print("Verifying...")
    result = pd.read_sql("SELECT COUNT(*) FROM products", engine)
    print("Rows in products table:", result.iloc[0, 0])

    print("Done.")

if __name__ == "__main__":
    load_to_postgres()