-- ============================================
-- Zeptalytix: Pricing & Inventory SQL Queries
-- ============================================

-- 1. Average price by category
SELECT "Category", ROUND(AVG("Price")::numeric, 2) AS AvgPrice
FROM products
GROUP BY "Category"
ORDER BY AvgPrice DESC;

-- 2. Total estimated revenue by category
SELECT "Category", ROUND(SUM("EstimatedRevenue")::numeric, 2) AS TotalRevenue
FROM products
GROUP BY "Category"
ORDER BY TotalRevenue DESC;

-- 3. Total estimated revenue by store
SELECT "Store_ID", ROUND(SUM("EstimatedRevenue")::numeric, 2) AS TotalRevenue
FROM products
GROUP BY "Store_ID"
ORDER BY TotalRevenue DESC;

-- 4. Total estimated revenue by region
SELECT "Region", ROUND(SUM("EstimatedRevenue")::numeric, 2) AS TotalRevenue
FROM products
GROUP BY "Region"
ORDER BY TotalRevenue DESC;

-- 5. Products priced above competitor pricing (pricing risk)
SELECT "Product_ID", "Category", "Price", "Competitor_Pricing", "PriceGapVsCompetitor"
FROM products
WHERE "PriceGapVsCompetitor" > 0
ORDER BY "PriceGapVsCompetitor" DESC
LIMIT 20;

-- 6. Products priced below competitor pricing (potential margin opportunity)
SELECT "Product_ID", "Category", "Price", "Competitor_Pricing", "PriceGapVsCompetitor"
FROM products
WHERE "PriceGapVsCompetitor" < 0
ORDER BY "PriceGapVsCompetitor" ASC
LIMIT 20;

-- 7. Stockout frequency by product
SELECT "Product_ID", SUM("StockoutFlag") AS StockoutCount
FROM products
GROUP BY "Product_ID"
ORDER BY StockoutCount DESC
LIMIT 10;

-- 8. Stockout rate by category
SELECT "Category",
       ROUND(100.0 * SUM("StockoutFlag") / COUNT(*), 2) AS StockoutRatePct
FROM products
GROUP BY "Category"
ORDER BY StockoutRatePct DESC;

-- 9. Average inventory level by category
SELECT "Category", ROUND(AVG("Inventory_Level")::numeric, 2) AS AvgInventory
FROM products
GROUP BY "Category"
ORDER BY AvgInventory DESC;

-- 10. Units sold vs units ordered (demand mismatch)
SELECT "Product_ID",
       SUM("Units_Sold") AS TotalSold,
       SUM("Units_Ordered") AS TotalOrdered,
       SUM("Units_Ordered") - SUM("Units_Sold") AS Surplus
FROM products
GROUP BY "Product_ID"
ORDER BY Surplus DESC
LIMIT 10;

-- 11. Monthly revenue trend
SELECT DATE_TRUNC('month', "Date") AS Month, ROUND(SUM("EstimatedRevenue")::numeric, 2) AS Revenue
FROM products
GROUP BY Month
ORDER BY Month;

-- 12. Seasonality impact on revenue
SELECT "Seasonality", ROUND(SUM("EstimatedRevenue")::numeric, 2) AS Revenue
FROM products
GROUP BY "Seasonality"
ORDER BY Revenue DESC;

-- 13. Weather impact on units sold
SELECT "Weather_Condition", ROUND(AVG("Units_Sold")::numeric, 2) AS AvgUnitsSold
FROM products
GROUP BY "Weather_Condition"
ORDER BY AvgUnitsSold DESC;

-- 14. Holiday/Promotion impact on sales
SELECT "Holiday_Promotion",
       ROUND(AVG("Units_Sold")::numeric, 2) AS AvgUnitsSold,
       ROUND(AVG("EstimatedRevenue")::numeric, 2) AS AvgRevenue
FROM products
GROUP BY "Holiday_Promotion";

-- 15. Discount effectiveness (does higher discount = more units sold?)
SELECT "Discount", ROUND(AVG("Units_Sold")::numeric, 2) AS AvgUnitsSold
FROM products
GROUP BY "Discount"
ORDER BY "Discount";

-- 16. Demand forecast accuracy (difference between forecast and actual units sold)
SELECT "Product_ID",
       ROUND(AVG("Demand_Forecast" - "Units_Sold")::numeric, 2) AS AvgForecastError
FROM products
GROUP BY "Product_ID"
ORDER BY ABS(AVG("Demand_Forecast" - "Units_Sold")) DESC
LIMIT 10;

-- 17. Top 5 products by revenue per store (window function: RANK)
WITH ranked AS (
    SELECT "Store_ID", "Product_ID",
           SUM("EstimatedRevenue") AS Revenue,
           RANK() OVER (PARTITION BY "Store_ID" ORDER BY SUM("EstimatedRevenue") DESC) AS rnk
    FROM products
    GROUP BY "Store_ID", "Product_ID"
)
SELECT * FROM ranked WHERE rnk <= 5;

-- 18. Running total of revenue over time (window function)
WITH monthly AS (
    SELECT DATE_TRUNC('month', "Date") AS Month, SUM("EstimatedRevenue") AS Revenue
    FROM products
    GROUP BY Month
)
SELECT Month, Revenue,
       SUM(Revenue) OVER (ORDER BY Month) AS RunningTotal
FROM monthly
ORDER BY Month;

-- 19. Revenue contribution percentage by category (CTE + window function)
WITH category_revenue AS (
    SELECT "Category", SUM("EstimatedRevenue") AS Revenue
    FROM products
    GROUP BY "Category"
)
SELECT "Category", Revenue,
       ROUND(100.0 * Revenue / SUM(Revenue) OVER (), 2) AS PctOfTotal
FROM category_revenue
ORDER BY Revenue DESC;

-- 20. Price volatility by product (standard deviation of price)
SELECT "Product_ID", ROUND(STDDEV("Price")::numeric, 2) AS PriceStdDev
FROM products
GROUP BY "Product_ID"
ORDER BY PriceStdDev DESC
LIMIT 10;

-- 21. Month-over-month revenue growth (window function: LAG)
WITH monthly AS (
    SELECT DATE_TRUNC('month', "Date") AS Month, SUM("EstimatedRevenue") AS Revenue
    FROM products
    GROUP BY Month
)
SELECT Month, Revenue,
       LAG(Revenue) OVER (ORDER BY Month) AS PrevMonthRevenue,
       ROUND(100.0 * (Revenue - LAG(Revenue) OVER (ORDER BY Month)) / LAG(Revenue) OVER (ORDER BY Month), 2) AS MoMGrowthPct
FROM monthly
ORDER BY Month;

-- 22. Store performance ranking (CTE + dense rank)
WITH store_revenue AS (
    SELECT "Store_ID", SUM("EstimatedRevenue") AS Revenue
    FROM products
    GROUP BY "Store_ID"
)
SELECT "Store_ID", Revenue,
       DENSE_RANK() OVER (ORDER BY Revenue DESC) AS StoreRank
FROM store_revenue;