import pandas as pd

df = pd.read_csv("data/raw_products.csv")
print("Columns:", list(df.columns))
print("\nShape:", df.shape)
print("\nFirst 5 rows:")
print(df.head())
print("\nData types:")
print(df.dtypes)