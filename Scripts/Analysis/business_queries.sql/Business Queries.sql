/*=========================================================
        BUSINESS ANALYSIS QUERIES
===========================================================

Purpose:
This script demonstrates how the Gold Layer can be used
to answer common business questions using SQL.

Author : Maram VijayReddy
Database : MySQL
=========================================================*/

USE DataWarehouse;
/*=========================================================
1. Total Revenue
=========================================================*/

SELECT
    ROUND(SUM(sales_amount),2) AS total_revenue
FROM gold_fact_sales;


/*=========================================================
2. Total Orders
=========================================================*/

SELECT COUNT(DISTINCT order_number) AS total_orders
FROM gold_fact_sales;
/*=========================================================
3. Total Customers
=========================================================*/

SELECT COUNT(*) AS total_customers
FROM gold_dim_customers;


/*=========================================================
4. Total Products
=========================================================*/

SELECT COUNT(*) AS total_products
FROM gold_dim_products;


/*=========================================================
5. Revenue by Country
=========================================================*/

SELECT
    c.country,
    ROUND(SUM(f.sales_amount),2) AS revenue
FROM gold_fact_sales f
JOIN gold_dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.country
ORDER BY revenue DESC;


/*=========================================================
6. Top 10 Customers by Revenue
=========================================================*/

SELECT
    c.customer_key,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    ROUND(SUM(f.sales_amount),2) AS revenue
FROM gold_fact_sales f
JOIN gold_dim_customers c
ON f.customer_key=c.customer_key
GROUP BY
    c.customer_key,
    customer_name
ORDER BY revenue DESC
LIMIT 10;


/*=========================================================
7. Top 10 Products
=========================================================*/

SELECT
    p.product_name,
    SUM(f.quantity) AS total_quantity
FROM gold_fact_sales f
JOIN gold_dim_products p
ON f.product_key=p.product_key
GROUP BY p.product_name
ORDER BY total_quantity DESC
LIMIT 10;

/*=========================================================
8. Revenue by Category
=========================================================*/

SELECT
    p.category,
    ROUND(SUM(f.sales_amount),2) revenue
FROM gold_fact_sales f
JOIN gold_dim_products p
ON f.product_key=p.product_key
GROUP BY p.category
ORDER BY revenue DESC;


/*=========================================================
9. Monthly Revenue Trend
=========================================================*/

SELECT
    DATE_FORMAT(order_date,'%Y-%m') AS month,
    ROUND(SUM(sales_amount),2) revenue
FROM gold_fact_sales
GROUP BY month
ORDER BY month;


/*=========================================================
10. Yearly Revenue
=========================================================*/

SELECT
    YEAR(order_date) AS year,
    ROUND(SUM(sales_amount),2) revenue
FROM gold_fact_sales
GROUP BY year
ORDER BY year;

/*=========================================================
11. Average Order Value
=========================================================*/

SELECT
ROUND(
SUM(sales_amount)/
COUNT(DISTINCT order_number)
,2) AS average_order_value
FROM gold_fact_sales;

/*=========================================================
12. Best Performing Category
=========================================================*/

SELECT
category,
ROUND(SUM(f.sales_amount),2) revenue
FROM gold_fact_sales f
JOIN gold_dim_products p
ON f.product_key=p.product_key
GROUP BY category
ORDER BY revenue DESC
LIMIT 1;


/*=========================================================
13. Customer Distribution by Gender
=========================================================*/

SELECT
gender,
COUNT(*) total_customers
FROM gold_dim_customers
GROUP BY gender;




/*=========================================================
14. Products per Category
=========================================================*/

SELECT
category,
COUNT(*) products
FROM gold_dim_products
GROUP BY category;

/*=========================================================
15. Monthly Quantity Sold
=========================================================*/

SELECT
DATE_FORMAT(order_date,'%Y-%m') Month,
SUM(quantity) Quantity
FROM gold_fact_sales
GROUP BY Month
ORDER BY Month;


/*=========================================================
16. Highest Revenue Month
=========================================================*/

SELECT
DATE_FORMAT(order_date,'%Y-%m') Month,
ROUND(SUM(sales_amount),2) Revenue
FROM gold_fact_sales
GROUP BY Month
ORDER BY Revenue DESC
LIMIT 1;


/*=========================================================
17. Top Countries by Revenue
=========================================================*/

SELECT
c.country,
ROUND(SUM(f.sales_amount),2) Revenue
FROM gold_fact_sales f
JOIN gold_dim_customers c
ON f.customer_key=c.customer_key
GROUP BY c.country
ORDER BY Revenue DESC
LIMIT 5;


/*=========================================================
18. Revenue by Marital Status
=========================================================*/

SELECT
c.marital_status,
ROUND(SUM(f.sales_amount),2) Revenue
FROM gold_fact_sales f
JOIN gold_dim_customers c
ON f.customer_key=c.customer_key
GROUP BY c.marital_status;


/*=========================================================
19. Average Selling Price
=========================================================*/

SELECT
ROUND(AVG(price),2) AS average_price
FROM gold_fact_sales;


/*=========================================================
20. Top Revenue Generating Products
=========================================================*/

SELECT
p.product_name,
ROUND(SUM(f.sales_amount),2) Revenue
FROM gold_fact_sales f
JOIN gold_dim_products p
ON f.product_key=p.product_key
GROUP BY p.product_name
ORDER BY Revenue DESC
LIMIT 10;