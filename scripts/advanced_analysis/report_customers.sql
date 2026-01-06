/*
-- ================================================================
					          	Customer Report
-- ================================================================
Purpose:
	- This report consolidates key customer metrics and behaviors
Highlights:
	1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
	3. Aggregates customer-level metrics:
		-> total orders
		-> total sales
		-> total quantity purchased
		-> total products
		-> lifespan (in months)
	4. Calculates valuable KPIs:
		-> recency (months since last order)
		-> average order value
		-> average monthly spend
-- ================================================================
*/
CREATE VIEW gold.customer_report AS
WITH base_query AS(
/* ----------------------------------------------------------------
1) Base Query: Retrieves the core columns from the tables.
---------------------------------------------------------------- */
SELECT
	sls.order_number,
    sls.product_key,
    sls.order_date,
    sls.sales_amount,
    sls.quantity,
    cu.customer_key,
    cu.customer_number,
    CONCAT(cu.first_name, ' ', cu.last_name) AS customer_name,
    TIMESTAMPDIFF(YEAR, cu.birth_date, CURDATE()) AS age
FROM gold.fact_sales sls
LEFT JOIN gold.dim_customers cu
ON sls.customer_key=cu.customer_key
WHERE order_date IS NOT NULL
), customer_aggregation AS(
/* --------------------------------------------------------------------
1) Customer Aggregations: Summarizes key metrics at the customer level
-------------------------------------------------------------------- */
SELECT
	customer_key,
    customer_number,
    customer_name,
    age,
    COUNT(DISTINCT order_number) AS total_orders,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT product_key) AS total_products,
    MAX(order_date) AS last_order_date,
    TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
GROUP BY customer_key, customer_number, customer_name, age
)
SELECT
	customer_key,
    customer_number,
    customer_name,
	CASE
		WHEN lifespan>=12 AND total_sales>5000 THEN 'VIP'
		WHEN lifespan>=12 AND total_sales<=5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,
    age,
    CASE
		WHEN age<20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 and above'
    END AS age_group,
    TIMESTAMPDIFF(MONTH, last_order_date, CURDATE()) AS recency_months,
    -- average_order_value(AOV)=total_sales/total_orders
    CASE
		WHEN total_orders=0 THEN 0
        ELSE ROUND(total_sales/total_orders)
    END AS avg_order_value,
    -- average_monthly_spend = total_sales/lifespan(customers first order date to last order date)
	CASE
		WHEN lifespan=0 THEN total_sales
        ELSE ROUND(total_sales/lifespan)
    END AS avg_monthly_spend,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan
FROM customer_aggregation;

SELECT * FROM customer_report;
