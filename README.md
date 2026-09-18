# NovaMart Supply Chain, Inventory & Procurement Analytics

An end-to-end analytics project using **SQL, Power BI, DAX, and data modeling** to evaluate sales, inventory health, warehouse performance, procurement efficiency, and supplier reliability for a fictional mid-sized omnichannel retail company.

## Project Overview

NovaMart’s operational data is distributed across products, suppliers, warehouses, purchase orders, and inventory transactions. This project consolidates those data sources into SQL analysis and an interactive two-page Power BI dashboard to identify operational trends, inventory risks, and supplier-performance gaps.

## Objectives

- Monitor sales trends and category performance
- Evaluate warehouse sales contribution
- Identify low-stock and stockout conditions
- Compare current inventory with demand
- Measure purchase-order fulfillment
- Analyze supplier fill rate and on-time delivery
- Highlight suppliers requiring closer monitoring

## Dataset

The Excel dataset contains the following tables:

### Products
`Product_ID`, `Product_Name`, `Category`, `Subcategory`, `Unit_Cost`, `Selling_Price`, `Reorder_Level`

### Suppliers
`Supplier_ID`, `Supplier_Name`, `Supplier_Category`, `Supplier_City`, `Standard_Lead_Days`

### Warehouses
`Warehouse_ID`, `Warehouse_Name`, `Region`, `City`

### Purchase_Orders
`PO_ID`, `Supplier_ID`, `Product_ID`, `Warehouse_ID`, `Order_Date`, `Expected_Date`, `Received_Date`, `Ordered_Qty`, `Received_Qty`, `Unit_Cost`, `Status`

### Inventory_Sales
`Inventory_Date`, `Warehouse_ID`, `Product_ID`, `Opening_Stock`, `Received_Qty`, `Sold_Qty`, `Closing_Stock`

## Tools & Technologies

- SQL
- Microsoft Power BI
- DAX
- Power Query
- Data Modeling
- Excel

## Project Workflow

```text
Excel Dataset
     ↓
SQL Data Exploration & Business Analysis
     ↓
Power BI Data Modeling and DAX
     ↓
Interactive Two-Page Dashboard
     ↓
Business Insights
```

## SQL Analysis

The SQL script answers business questions related to:

- Slow-moving and unsold products
- Top-selling products by warehouse and category
- Warehouse sales performance
- Suppliers with the highest supplied quantities
- Suppliers with above-average lead times
- Products below their reorder levels
- Supplier unfulfilled-quantity percentages
- Product profit potential
- Suppliers supplying more than a defined quantity threshold
- Top products by current inventory for each warehouse
- Products performing above the overall sales average
- Warehouse contribution to product-level sales

### SQL Concepts Demonstrated

`JOIN`, `GROUP BY`, `HAVING`, `CASE`, `CTE`, subqueries, `NOT EXISTS`, aggregate functions, date filtering, conditional calculations, `ROW_NUMBER()`, `DENSE_RANK()`, and window functions.

## Power BI Dashboard

### Page 1 — Inventory & Sales Performance

Provides a consolidated view of sales trends, category performance, warehouse sales, current inventory, and inventory health.

**KPIs**
- Total Units Sold
- Current Closing Stock
- Low Stock Items
- Stockout Items

**Visuals**
- Monthly Sales Volume
- Current Inventory by Category
- Sales Volume by Category
- Sales Volume by Warehouse
- Inventory Health
- Interactive Month, Year, Warehouse, and Category filters

### Page 2 — Procurement & Supplier Performance

Evaluates purchase-order activity, fulfillment, delivery reliability, and supplier performance.

**KPIs**
- Total Purchase Orders
- Ordered Quantity
- Received Quantity
- PO Fill Rate %
- On-Time Delivery %

**Visuals**
- Purchase Orders Over Time
- Bottom 10 Suppliers by On-Time Delivery %
- Purchase Order Status
- Bottom 10 Suppliers by Fill Rate %
- Interactive Month and Year filters

## KPI Definitions

- **Current Closing Stock:** Closing stock based on the latest available inventory date.
- **Low Stock Items:** Latest closing stock below the product-specific reorder level.
- **Stockout Items:** Latest closing stock equal to zero.
- **PO Fill Rate:** Received quantity divided by ordered quantity.
- **On-Time Delivery %:** Percentage of purchase orders received on or before the expected delivery date.
- **Unfulfilled Quantity:** Ordered quantity minus received quantity.

## Key Insights

- 2024 sales volume was stronger than 2025, with peak monthly sales in October 2024.
- Grocery and Electronics led category sales, while Sports recorded the lowest sales volume.
- Home & Kitchen and Sports held the highest current inventory levels.
- W001 and W004 were the strongest warehouses by sales volume.
- A notable portion of inventory required attention due to low-stock and stockout conditions.
- Overall PO fill rate was approximately **90.72%**.
- Overall on-time delivery performance was approximately **26.43%**, indicating delivery-reliability concerns.
- The bottom-performing suppliers by fill rate and on-time delivery can be prioritized for follow-up and monitoring.

## How to Use

1. Import the Excel dataset into a SQL environment.
2. Run the SQL script to reproduce the business analysis.
3. Open the Power BI report.
4. Update the source path if required.
5. Refresh the data model and explore the dashboard filters.

## Project Highlights

- Transformed operational data into business-focused analysis
- Used SQL to answer practical supply-chain questions
- Built a focused two-page Power BI dashboard
- Applied DAX for inventory, fulfillment, and delivery KPIs
- Compared suppliers using fill rate and on-time delivery
- Converted analytical findings into actionable business insights

## Disclaimer

NovaMart is a fictional retail company created for portfolio and learning purposes.
