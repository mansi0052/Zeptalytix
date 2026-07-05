# Zeptalytix: Automated Pricing & Inventory Analytics Pipeline

A scalable, containerized ETL pipeline that automates the extraction of pricing and inventory insights from retail product data — built with Python, PostgreSQL, and Docker for reliable, repeatable analysis.

## 📌 Overview

Zeptalytix automates the end-to-end process of cleaning, loading, and analyzing retail product data to support pricing strategy and inventory decisions. Unlike a one-off analysis, this project emphasizes **automation and reproducibility** — the entire pipeline runs with a single command and produces identical results on any machine.

**Dataset:** Retail Store Inventory and Sales Data (Kaggle) — 73,100+ records across 5 stores and 20 products, covering pricing, inventory levels, demand forecasts, competitor pricing, promotions, and seasonality.

## 🎯 Key Results

- Engineered a SQL-driven ETL pipeline cleaning and validating **73,100+ product records** at scale
- Extracted pricing and inventory insights through **22 advanced SQL queries** — aggregations, CTEs, and window functions (RANK, LAG, DENSE_RANK)
- Automated the full ingestion → cleaning → loading → validation workflow into a **single command**, replacing a multi-step manual process
- Containerized the entire pipeline with Docker, enabling identical execution across environments with zero manual setup

## 🛠️ Tech Stack

- **Python** (pandas) — data cleaning and feature engineering
- **PostgreSQL** — production-grade relational database for query analysis
- **SQL** — aggregations, CTEs, window functions
- **Docker & Docker Compose** — containerized, reproducible pipeline execution

## 📂 Project Structure
Zeptalytix/
├── data/
│   ├── raw_products.csv
│   └── cleaned_products.csv
├── src/
│   ├── data_cleaning.py
│   ├── load_to_postgres.py
│   ├── run_pg_queries.py
│   └── run_pipeline.py
├── sql/
│   └── queries.sql
├── Dockerfile
├── docker-compose.yml
├── requirements.txt
└── README.md

## 🔄 Pipeline

1. **Data Cleaning** (`data_cleaning.py`) — removes invalid/missing records, engineers derived features: `PriceGapVsCompetitor`, `EstimatedRevenue`, `StockoutFlag`
2. **Load to PostgreSQL** (`load_to_postgres.py`) — writes cleaned data into a PostgreSQL database, reading connection config from environment variables for portability
3. **SQL Analysis** (`queries.sql`) — 22 business queries covering pricing gaps, stockout patterns, seasonal trends, revenue ranking, and month-over-month growth
4. **Automated Orchestration** (`run_pipeline.py`) — runs all steps sequentially with timing and pass/fail validation

## 📊 Query Highlights

- Pricing risk: products priced above/below competitor pricing
- Stockout frequency and rate by product/category
- Monthly revenue trend with running totals (window functions)
- Month-over-month revenue growth (LAG)
- Store performance ranking (DENSE_RANK)
- Revenue contribution % by category (CTE + window function)

## 🚀 How to Run

### Option 1: Locally
```bash
pip install -r requirements.txt
python src/run_pipeline.py
```
*(Requires a local PostgreSQL instance; update credentials in `src/load_to_postgres.py`)*

### Option 2: Docker (recommended — no local setup required)
```bash
docker-compose up --build
```
This spins up a PostgreSQL container and runs the full pipeline automatically — cleaning, loading, and validating 73,100+ records in under a minute.

## 💡 Methodology Notes

- **PostgreSQL over SQLite** — chosen to reflect a production-realistic setup and support advanced SQL features (window functions, CTEs) at scale.
- **Environment-variable-based configuration** — connection details are read dynamically, allowing the same codebase to run seamlessly both locally and inside Docker without code changes.
- **Docker Compose orchestration** — packages the pipeline and database together, solving the "works on my machine" problem and ensuring consistent, reproducible results across environments.
