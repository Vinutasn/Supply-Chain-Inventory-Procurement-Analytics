DROP TABLE IF EXISTS Products;
CREATE TABLE Products (
    Product_ID VARCHAR(20) PRIMARY KEY,
    Product_Name VARCHAR(150),
    Category VARCHAR(100),
    Subcategory VARCHAR(100),
    Unit_Cost NUMERIC(10,2),
    Selling_Price NUMERIC(10,2),
    Reorder_Level INT
);

DROP TABLE IF EXISTS Suppliers;
CREATE TABLE Suppliers (
    Supplier_ID VARCHAR(20) PRIMARY KEY,
    Supplier_Name VARCHAR(150),
    Supplier_Category VARCHAR(100),
    Supplier_City VARCHAR(100),
    Standard_Lead_Days INT
);

DROP TABLE IF EXISTS Warehouses;
CREATE TABLE Warehouses (
    Warehouse_ID VARCHAR(20) PRIMARY KEY,
    Warehouse_Name VARCHAR(150),
    Region VARCHAR(100),
    City VARCHAR(100)
);

DROP TABLE IF EXISTS Purchase_Orders;
CREATE TABLE Purchase_Orders (
    PO_ID VARCHAR(20),
    Supplier_ID VARCHAR(20),
    Product_ID VARCHAR(20),
    Warehouse_ID VARCHAR(20),
    Order_Date DATE,
    Expected_Date DATE,
    Received_Date DATE,
    Ordered_Qty INT,
    Received_Qty INT,
    Unit_Cost NUMERIC(10,2),
    Status VARCHAR(50)
);

DROP TABLE IF EXISTS Inventory_Sales;
CREATE TABLE Inventory_Sales (
    Inventory_Date DATE,
    Warehouse_ID VARCHAR(20),
    Product_ID VARCHAR(20),
    Opening_Stock INT,
    Received_Qty INT,
    Sold_Qty INT,
    Closing_Stock INT
);

SELECT * FROM Products;
SELECT COUNT(*) FROM Products;

SELECT * FROM Suppliers;
SELECT COUNT(*) FROM Suppliers;

SELECT * FROM Warehouses;
SELECT COUNT(*) FROM Warehouses;

SELECT * FROM Purchase_Orders;
SELECT COUNT(*) FROM Purchase_Orders;

SELECT * FROM Inventory_Sales;
SELECT COUNT(*) FROM Inventory_Sales;

--1. Which products are slow-moving based on their sales/demand quantity?
SELECT i.product_id, p.product_name, SUM(i.sold_qty) AS total_qty_sold
FROM inventory_sales i
JOIN products p
ON i.product_id=p.product_id
GROUP BY i.product_id, p.product_name
ORDER BY SUM(i.sold_qty);

--2. Which products generated the highest total sales quantity in each warehouse during 2025?
WITH CTE AS(
SELECT i.warehouse_id, i.product_id, p.product_name, SUM(i.sold_qty) AS total_sold_qty,
ROW_NUMBER() OVER (PARTITION BY i.warehouse_id ORDER BY SUM(i.sold_qty) DESC) AS rn
FROM inventory_sales i
JOIN products p
ON i.product_id=p.product_id
WHERE i.inventory_date>='2025-01-01' AND i.inventory_date<='2025-12-31'
GROUP BY i.warehouse_id, i.product_id, p.product_name
)

SELECT warehouse_id, product_id, product_name,total_sold_qty
FROM CTE
WHERE rn=1
ORDER BY warehouse_id;

--3. Which warehouses sold the highest quantity of products during 2025?
SELECT warehouse_id, SUM(sold_qty) AS highest_qty_sold
FROM inventory_sales
WHERE inventory_date>='2025-01-01' AND inventory_date<'2026-01-01'
GROUP BY warehouse_id
ORDER BY highest_qty_sold DESC;

--4. Which products have never been sold from any warehouse during 2025?
SELECT product_id, product_name
FROM products p
WHERE NOT EXISTS(
	SELECT 1
	FROM inventory_sales i
	WHERE i.product_id=p.product_id
	AND inventory_date>='2025-01-01' 
	AND inventory_date<'2026-01-01');

--5. Which suppliers supplied the highest total quantity of products during 2025?
SELECT p.supplier_id, s.supplier_name, SUM(received_qty) AS highest_total_qty
FROM purchase_orders p
JOIN suppliers s
ON p.supplier_id=s.supplier_id
WHERE p.status='Received'
AND p.received_date>='2025-01-01' AND p.received_date<'2026-01-01'
GROUP BY p.supplier_id, s.supplier_name
ORDER BY highest_total_qty desc
LIMIT 1;

--6. Which suppliers have a standard lead time greater than the overall average supplier lead time?
SELECT supplier_id, supplier_name, standard_lead_days
FROM suppliers
WHERE standard_lead_days>
	(SELECT AVG(standard_lead_days)
	FROM suppliers)
ORDER BY supplier_id;

--7. Which products are currently below their reorder level?
WITH latest AS(
SELECT product_id, warehouse_id, closing_stock,
ROW_NUMBER() OVER (PARTITION BY product_id, warehouse_id ORDER BY inventory_date DESC) AS rn
FROM inventory_sales
)

SELECT l.product_id, l.warehouse_id, l.closing_stock, p.reorder_level
FROM latest l
JOIN products p
ON l.product_id=p.product_id
WHERE rn=1
AND l.closing_stock<p.reorder_level;

--8. Which suppliers have the highest percentage of unfulfilled quantity on their purchase orders?

WITH CTE AS(
SELECT p.supplier_id, s.supplier_name, SUM(p.ordered_qty) AS total_ordered_qty, SUM(p.received_qty) AS total_received_qty
FROM purchase_orders p
JOIN suppliers s
ON p.supplier_id=s.supplier_id
WHERE p.status IN ('Partially Received', 'Received')
GROUP BY p.supplier_id, s.supplier_name
ORDER BY p.supplier_id
)

SELECT *, ROUND((total_ordered_qty-total_received_qty)*100.0/(total_ordered_qty),2) AS unfulfilled_percentage
FROM CTE
ORDER BY unfulfilled_percentage DESC;

-- 9. Which products have the highest total profit potential based on their selling price and unit cost?
SELECT product_id, product_name, selling_price, unit_cost, (selling_price-unit_cost) AS profit_per_unit
FROM products
ORDER BY profit_per_unit DESC;

--10. Which suppliers have supplied more than 5,000 units to our warehouses in total?
SELECT p.supplier_id, s.supplier_name, SUM(p.received_qty) AS total_supplied_qty
FROM purchase_orders p
JOIN suppliers s
ON p.supplier_id=s.supplier_id
GROUP BY p.supplier_id, s.supplier_name
HAVING SUM(p.received_qty)>5000
ORDER BY total_supplied_qty desc;

--11. Which product categories have sold more than 10,000 units in total?
SELECT p.category, SUM(i.sold_qty) AS total_sold_qty
FROM products p
JOIN inventory_sales i
ON p.product_id=i.product_id
GROUP BY p.category
HAVING SUM(i.sold_qty)>10000
ORDER BY total_sold_qty DESC;

--12. For each warehouse, identify the top 3 products with the highest current inventory quantity.
WITH CTE AS(
SELECT i.warehouse_id, w.warehouse_name, p.product_id, p.product_name, SUM(i.closing_stock) AS current_inventory,
	DENSE_RANK() OVER (PARTITION BY i.warehouse_id ORDER BY SUM(i.closing_stock) DESC) AS inventory_rank
FROM inventory_sales i
JOIN warehouses w
ON i.warehouse_id=w.warehouse_id
JOIN products p
ON i.product_id=p.product_id
GROUP BY i.warehouse_id, w.warehouse_name, p.product_id, p.product_name
)
SELECT * FROM CTE
WHERE inventory_rank<=3;

--13. For each product category, rank the products based on their total quantity sold, and return only the top 2 products from each category.
WITH CTE AS(
SELECT p.category, i.product_id, p.product_name, SUM(i.sold_qty) AS total_sold_qty,
	DENSE_RANK() OVER (PARTITION BY p.category ORDER BY SUM(i.sold_qty) DESC) AS rn
FROM products p
JOIN inventory_sales i
ON p.product_id=i.product_id
GROUP BY p.category, i.product_id, p.product_name
)
SELECT category, product_id, product_name, total_sold_qty 
FROM CTE
WHERE rn<=2;

--14. For each product, compare its total quantity sold with the average total quantity sold across all products, and identify the products whose sales are above the overall product average.
WITH CTE AS(
SELECT i.product_id, p.product_name, SUM(i.sold_qty) AS total_sold_qty
FROM inventory_sales i
JOIN products p
ON i.product_id=p.product_id
GROUP BY 1,2 
),
CTE1 AS(
SELECT *, ROUND(AVG(total_sold_qty) OVER(),2) AS avg_total_sold_qty
FROM CTE
)
SELECT * FROM CTE1
WHERE total_sold_qty>avg_total_sold_qty;
ORDER BY product_id;

--15. For each product, calculate its total quantity sold and the percentage of the product's sales contributed by each warehouse.
WITH CTE AS(
SELECT i.product_id, p.product_name, i.warehouse_id, w.warehouse_name, SUM(i.sold_qty) AS warehouse_sold_qty
FROM products p
JOIN inventory_sales i
ON p.product_id=i.product_id
JOIN warehouses w
ON w.warehouse_id=i.warehouse_id
GROUP BY 1,2,3,4
),
CTE1 AS(
SELECT *, SUM(warehouse_sold_qty) OVER (PARTITION BY product_id ORDER BY product_id) AS warehouse_sales
FROM CTE
) 
SELECT *, ROUND((warehouse_sold_qty*100.0/warehouse_sales),2) AS warehouse_sales_percentage
FROM CTE1;
