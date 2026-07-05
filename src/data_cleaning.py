import pandas as pd

def clean_data():
    print("Loading raw data...")
    df = pd.read_csv("data/raw_products.csv", parse_dates=["Date"])
    print(f"Original rows: {len(df)}")

    # Standardize column names (remove spaces, slashes for easier SQL/Python use)
    df.columns = [c.strip().replace(" ", "_").replace("/", "_") for c in df.columns]
    print("Standardized columns:", list(df.columns))

    # Drop rows with any missing critical values
    critical_cols = ["Store_ID", "Product_ID", "Price", "Inventory_Level", "Units_Sold"]
    df = df.dropna(subset=critical_cols)

    # Remove invalid rows: negative or zero price, negative inventory
    df = df[(df["Price"] > 0) & (df["Inventory_Level"] >= 0)]

    # Remove exact duplicates
    df = df.drop_duplicates()

    # Feature: Price gap vs competitor (useful for pricing strategy queries)
    df["PriceGapVsCompetitor"] = df["Price"] - df["Competitor_Pricing"]

    # Feature: Revenue estimate (Units Sold * Price after discount)
    df["EffectivePrice"] = df["Price"] * (1 - df["Discount"] / 100)
    df["EstimatedRevenue"] = df["Units_Sold"] * df["EffectivePrice"]

    # Feature: Stockout flag (inventory ran out)
    df["StockoutFlag"] = (df["Inventory_Level"] == 0).astype(int)

    print(f"Cleaned rows: {len(df)}")

    df.to_csv("data/cleaned_products.csv", index=False)
    print("Saved to data/cleaned_products.csv")

    return df

if __name__ == "__main__":
    clean_data()