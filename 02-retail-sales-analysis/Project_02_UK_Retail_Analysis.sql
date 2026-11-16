-- PROJECT 02 | UK ONLINE RETAIL SALES PERFORMANCE ANALYSIS
-- Independent Business Analyst portfolio case study
-- Source: UCI Online Retail, December 2010 to 9 December 2011
-- Database: UK_Retail_Analysis_NEW.db (or user's working database)
-- Source table: UK_Online_Retail_Raw
-- Cleaned view: UK_Retail_Valid_Sales
--
-- IMPORTANT
-- 1. These are SELECT queries only: they do not alter the database.
-- 2. Each query can be run independently in DB Browser for SQLite.
-- 3. Revenue measures qualifying POSITIVE sales, NOT net revenue or profit.
-- 4. Do not silently exclude unusual orders from main KPIs; sensitivity checks
--    below are separate scenarios and should be labelled accordingly.
-- 5. The product-code lists are a practical screening rule, not a verified
--    complete product master list.

-- ================================================================
-- 01 | DATA QUALITY / CHECKS (BQ-06)
-- ================================================================

-- Original imported line-item count (observed: 541,909)
SELECT COUNT(*) AS Raw_Line_Items
FROM UK_Online_Retail_Raw;

-- Valid sales line-item count (observed: 530,104)
SELECT COUNT(*) AS Valid_Sales_Line_Items
FROM UK_Retail_Valid_Sales;

-- Cancellation / invalid-value counts (retained in raw table)
SELECT
    SUM(CASE WHEN UPPER(TRIM(InvoiceNo)) LIKE 'C%' THEN 1 ELSE 0 END)
        AS Cancellation_Line_Items,
    SUM(CASE WHEN CAST(Quantity AS REAL) < 0 THEN 1 ELSE 0 END)
        AS Negative_Quantity_Lines,
    SUM(CASE WHEN CAST(UnitPrice AS REAL) = 0 THEN 1 ELSE 0 END)
        AS Zero_Price_Lines,
    SUM(CASE WHEN CAST(UnitPrice AS REAL) < 0 THEN 1 ELSE 0 END)
        AS Negative_Price_Lines,
    SUM(CASE WHEN CustomerID IS NULL OR TRIM(CustomerID) = '' THEN 1 ELSE 0 END)
        AS Missing_CustomerID_Lines
FROM UK_Online_Retail_Raw;

-- Note: Existing view was created earlier with this logic:
-- CREATE VIEW UK_Retail_Valid_Sales AS
-- SELECT InvoiceNo, StockCode, Description, Quantity, InvoiceDate,
--        UnitPrice, CustomerID, Country,
--        Quantity * UnitPrice AS Revenue
-- FROM UK_Online_Retail_Raw
-- WHERE Quantity > 0
--   AND UnitPrice > 0
--   AND InvoiceNo NOT LIKE 'C%';

-- ================================================================
-- 02 | SALES KPIs (BQ-01)
-- ================================================================

-- Observed: £10,666,684.54; 19,960 orders; £534.40 AOV;
-- 5,588,376 units; 4,338 identified customers.
SELECT
    ROUND(SUM(Revenue), 2) AS Gross_Qualifying_Sales,
    COUNT(DISTINCT InvoiceNo) AS Total_Orders,
    ROUND(SUM(Revenue) / COUNT(DISTINCT InvoiceNo), 2)
        AS Average_Order_Value,
    SUM(Quantity) AS Units_Sold,
    COUNT(DISTINCT CASE
        WHEN CustomerID IS NOT NULL AND TRIM(CustomerID) <> ''
        THEN CustomerID END) AS Identifiable_Customers
FROM UK_Retail_Valid_Sales;

-- ================================================================
-- 03 | MONTHLY TREND / SALES DAYS (BQ-01, BQ-05)
-- ================================================================

-- Monthly totals, including the incomplete final month (2011-12)
SELECT
    SUBSTR(InvoiceDate, 7, 4) || '-' || SUBSTR(InvoiceDate, 4, 2)
        AS Sales_Month,
    ROUND(SUM(Revenue), 2) AS Monthly_Revenue,
    COUNT(DISTINCT InvoiceNo) AS Monthly_Orders
FROM UK_Retail_Valid_Sales
GROUP BY Sales_Month
ORDER BY Sales_Month;

-- Recorded sales days; exclude partial 2011-12 for comparison.
-- Note: Sales-day average is NOT calendar-day average.
SELECT
    SUBSTR(InvoiceDate, 7, 4) || '-' || SUBSTR(InvoiceDate, 4, 2)
        AS Sales_Month,
    COUNT(DISTINCT SUBSTR(InvoiceDate, 1, 10)) AS Recorded_Sales_Days,
    ROUND(SUM(Revenue), 2) AS Monthly_Revenue,
    ROUND(SUM(Revenue) /
          COUNT(DISTINCT SUBSTR(InvoiceDate, 1, 10)), 2)
        AS Revenue_Per_Recorded_Sales_Day
FROM UK_Retail_Valid_Sales
WHERE (SUBSTR(InvoiceDate, 7, 4) || '-' ||
       SUBSTR(InvoiceDate, 4, 2)) <> '2011-12'
GROUP BY Sales_Month
ORDER BY Revenue_Per_Recorded_Sales_Day DESC;

-- Date coverage: observed 2010-12-01 through 2011-12-09
SELECT
    MIN(SUBSTR(InvoiceDate, 7, 4) || '-' ||
        SUBSTR(InvoiceDate, 4, 2) || '-' ||
        SUBSTR(InvoiceDate, 1, 2)) AS First_Sale_Date,
    MAX(SUBSTR(InvoiceDate, 7, 4) || '-' ||
        SUBSTR(InvoiceDate, 4, 2) || '-' ||
        SUBSTR(InvoiceDate, 1, 2)) AS Last_Sale_Date
FROM UK_Retail_Valid_Sales;

-- ================================================================
-- 04 | PRODUCT PERFORMANCE (BQ-02)
-- ================================================================

-- Main rankings: one row per STANDARDISED StockCode.
-- MAX(Description) is a display example, not a validated product name.
-- Explicitly exclude known non-merchandise entries; retain outliers.
WITH ProductSales AS (
    SELECT
        UPPER(TRIM(StockCode)) AS Product_Code,
        MAX(Description) AS Example_Description,
        SUM(Quantity) AS Units_Sold,
        ROUND(SUM(Revenue), 2) AS Total_Revenue
    FROM UK_Retail_Valid_Sales
    WHERE UPPER(TRIM(StockCode)) NOT IN (
        'DOT', 'POST', 'M', 'AMAZONFEE', 'B', 'C2', 'BANK CHARGES'
    )
      AND UPPER(TRIM(StockCode)) NOT GLOB 'GIFT*'
    GROUP BY UPPER(TRIM(StockCode))
)
SELECT * FROM ProductSales
ORDER BY Total_Revenue DESC
LIMIT 10;

WITH ProductSales AS (
    SELECT
        UPPER(TRIM(StockCode)) AS Product_Code,
        MAX(Description) AS Example_Description,
        SUM(Quantity) AS Units_Sold,
        ROUND(SUM(Revenue), 2) AS Total_Revenue
    FROM UK_Retail_Valid_Sales
    WHERE UPPER(TRIM(StockCode)) NOT IN (
        'DOT', 'POST', 'M', 'AMAZONFEE', 'B', 'C2', 'BANK CHARGES'
    )
      AND UPPER(TRIM(StockCode)) NOT GLOB 'GIFT*'
    GROUP BY UPPER(TRIM(StockCode))
)
SELECT * FROM ProductSales
ORDER BY Units_Sold DESC
LIMIT 10;

-- Documented product identifier / description inconsistencies
SELECT
    UPPER(TRIM(StockCode)) AS Standardised_StockCode,
    Description,
    COUNT(*) AS Transaction_Lines,
    SUM(Quantity) AS Units_Sold,
    ROUND(SUM(Revenue), 2) AS Total_Revenue
FROM UK_Retail_Valid_Sales
WHERE UPPER(TRIM(StockCode)) IN ('85123A', '22197')
GROUP BY UPPER(TRIM(StockCode)), Description
ORDER BY Standardised_StockCode, Total_Revenue DESC;

-- Concentration of largest transaction line for selected product codes
SELECT
    UPPER(TRIM(StockCode)) AS Product_Code,
    COUNT(DISTINCT InvoiceNo) AS Total_Orders,
    SUM(Quantity) AS Total_Units,
    MAX(Quantity) AS Largest_Transaction_Line_Units,
    ROUND(MAX(Quantity) * 100.0 / SUM(Quantity), 2)
        AS Largest_Line_Unit_Share_Pct
FROM UK_Retail_Valid_Sales
WHERE UPPER(TRIM(StockCode)) IN ('22423', '23843', '23166', '84077')
GROUP BY UPPER(TRIM(StockCode))
ORDER BY Largest_Line_Unit_Share_Pct DESC;

-- Sensitivity scenario ONLY: omit two unusually large lines, but leave
-- main rankings, original view and database unchanged.
WITH ProductSalesSensitivity AS (
    SELECT
        UPPER(TRIM(StockCode)) AS Product_Code,
        MAX(Description) AS Example_Description,
        SUM(Quantity) AS Units_Sold,
        ROUND(SUM(Revenue), 2) AS Total_Revenue
    FROM UK_Retail_Valid_Sales
    WHERE UPPER(TRIM(StockCode)) NOT IN (
        'DOT', 'POST', 'M', 'AMAZONFEE', 'B', 'C2', 'BANK CHARGES'
    )
      AND UPPER(TRIM(StockCode)) NOT GLOB 'GIFT*'
      AND NOT (UPPER(TRIM(StockCode)) = '23843' AND InvoiceNo = '581483')
      AND NOT (UPPER(TRIM(StockCode)) = '23166' AND InvoiceNo = '541431')
    GROUP BY UPPER(TRIM(StockCode))
)
SELECT * FROM ProductSalesSensitivity
ORDER BY Units_Sold DESC
LIMIT 10;

-- ================================================================
-- 05 | CUSTOMER BEHAVIOUR (BQ-03)
-- ================================================================

-- Main rankings: retain all qualifying sales, including outliers.
SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS Total_Orders,
    ROUND(SUM(Revenue), 2) AS Total_Revenue,
    ROUND(SUM(Revenue) / COUNT(DISTINCT InvoiceNo), 2)
        AS Average_Order_Value
FROM UK_Retail_Valid_Sales
WHERE CustomerID IS NOT NULL AND TRIM(CustomerID) <> ''
GROUP BY CustomerID
ORDER BY Total_Revenue DESC
LIMIT 10;

-- Customer order frequency (observed: 1,493 / 1,973 / 535 / 337)
WITH CustomerOrders AS (
    SELECT CustomerID,
           COUNT(DISTINCT InvoiceNo) AS Order_Count
    FROM UK_Retail_Valid_Sales
    WHERE CustomerID IS NOT NULL AND TRIM(CustomerID) <> ''
    GROUP BY CustomerID
)
SELECT
    CASE
        WHEN Order_Count = 1 THEN '1 Order'
        WHEN Order_Count BETWEEN 2 AND 5 THEN '2-5 Orders'
        WHEN Order_Count BETWEEN 6 AND 10 THEN '6-10 Orders'
        ELSE '11+ Orders'
    END AS Purchase_Frequency,
    COUNT(*) AS Total_Customers
FROM CustomerOrders
GROUP BY Purchase_Frequency
ORDER BY MIN(Order_Count);

-- Customer sensitivity scenario: omit exceptional transaction lines.
SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS Total_Orders,
    ROUND(SUM(Revenue), 2) AS Total_Revenue,
    ROUND(SUM(Revenue) / COUNT(DISTINCT InvoiceNo), 2)
        AS Average_Order_Value
FROM UK_Retail_Valid_Sales
WHERE CustomerID IS NOT NULL AND TRIM(CustomerID) <> ''
  AND NOT (UPPER(TRIM(StockCode)) = '23843' AND InvoiceNo = '581483')
  AND NOT (UPPER(TRIM(StockCode)) = '23166' AND InvoiceNo = '541431')
GROUP BY CustomerID
ORDER BY Total_Revenue DESC
LIMIT 10;

-- ================================================================
-- 06 | GEOGRAPHIC PERFORMANCE (BQ-04)
-- ================================================================

-- Top 10 markets (UK observed: 84.61% of qualifying sales value)
SELECT
    Country,
    COUNT(DISTINCT InvoiceNo) AS Total_Orders,
    ROUND(SUM(Revenue), 2) AS Total_Revenue,
    ROUND(100.0 * SUM(Revenue) /
          (SELECT SUM(Revenue) FROM UK_Retail_Valid_Sales), 2)
          AS Revenue_Percentage
FROM UK_Retail_Valid_Sales
GROUP BY Country
ORDER BY Total_Revenue DESC
LIMIT 10;

-- UK vs International AOV (observed: UK £500.87 / overseas £845.68)
SELECT
    CASE WHEN Country = 'United Kingdom' THEN 'UK'
         ELSE 'International' END AS Market,
    COUNT(DISTINCT InvoiceNo) AS Total_Orders,
    ROUND(SUM(Revenue), 2) AS Total_Revenue,
    ROUND(SUM(Revenue) / COUNT(DISTINCT InvoiceNo), 2)
        AS Average_Order_Value
FROM UK_Retail_Valid_Sales
GROUP BY Market
ORDER BY Total_Revenue DESC;

-- ================================================================
-- NEXT: Power BI dashboard and final recommendations.
-- QA note: country labels describe recorded transaction countries,
-- not necessarily buyer nationality or destination profitability.
-- ================================================================
