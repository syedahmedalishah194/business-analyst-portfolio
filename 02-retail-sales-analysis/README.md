
# UK Online Retail Sales Performance Analysis

**Project Status:** Completed  
**Role:** Business Analyst | Data Analyst  
**Tools:** SQL (SQLite), Power BI, Excel  
**Dataset:** UCI Online Retail (December 2010 – December 2011)

## 1. Business Problem

A UK-based online retailer needs a clearer understanding of its sales performance, customer purchasing behaviour, product demand and geographic revenue distribution.

This independent Business Analyst case study uses historical transaction data to identify performance patterns, investigate unusual transactions and recommend data-informed business improvements.

## 2. Business Objectives

- Evaluate overall sales performance and monthly trends.
- Identify leading products by revenue and units sold.
- Analyse high-value customers and repeat purchasing.
- Compare domestic and international market performance.
- Investigate data-quality issues and exceptional transactions.

## 3. Data Preparation and Methodology

The original dataset contains **541,909 transaction lines**.

Using SQLite and Power BI, I:
- Excluded cancellations, non-positive quantities and non-positive prices from qualifying sales.
- Created a cleaned sales dataset containing **530,104 rows**.
- Developed SQL queries to analyse sales, products, customers and geography.
- Standardised product codes for consistent product rankings.
- Investigated unusually large transactions through separate sensitivity analysis.
- Built a four-page Power BI dashboard.

## 4. Key Performance Indicators

| KPI | Result |
|---|---:|
| Total qualifying sales revenue | £10,666,684.54 |
| Total orders | 19,960 |
| Average order value | £534.40 |
| Units sold | 5,588,376 |
| Identifiable customers | 4,338 |

Revenue represents positive, non-cancelled sales, not net revenue or profit.

## 5. Key Business Findings

### Sales Performance
November 2011 recorded the highest monthly sales revenue, approximately £1.51 million. December 2011 is incomplete and should not be directly compared with full months.

### Product Performance
Regency Cakestand 3 Tier generated the highest product revenue. Paper Craft, Little Birdie led in units sold, largely because of an unusually large transaction of 80,995 units.

### Customer Behaviour
Customer 14646 generated approximately £280,206 in revenue. Of the 4,338 identifiable customers, 1,973 placed 2–5 orders, while 1,493 placed only one order.

### Geographic Performance
The United Kingdom accounted for approximately 84.61% of qualifying sales revenue. The Netherlands, EIRE, Germany and France were important international markets.

## 6. Business Recommendations

1. Monitor high-revenue products to support inventory planning.
2. Investigate exceptional bulk purchases before using sales rankings for operational decisions.
3. Develop customer retention initiatives targeting one-time buyers.
4. Monitor international demand and market concentration.
5. Track monthly performance alongside data-quality and reporting limitations.

These recommendations are analytical proposals, not implemented business changes.

## 7. Power BI Dashboard

The dashboard contains four pages:

1. Sales Overview
2. Product Performance
3. Customer Analysis
4. Geographic Performance

**[View the Dashboard PDF](Project_02_UK_Retail_Dashboard.pdf)**

## 8. Project Files

- [SQL Analysis](Project_02_UK_Retail_Analysis.sql)
- [Power BI Dashboard](Project_02_UK_Retail_Dashboard.pbix)
- [Dashboard PDF](Project_02_UK_Retail_Dashboard.pdf)

**Data source:** UCI Machine Learning Repository – Online Retail dataset.

The raw dataset and SQLite database are not included in this repository. The SQL analysis file contains queries for the prepared raw table and cleaned view.

## 9. Skills Demonstrated

Business problem definition, SQL analysis, data cleaning, KPI development, customer segmentation, data-quality assessment, sensitivity analysis, Power BI dashboard development and evidence-based business recommendations.
