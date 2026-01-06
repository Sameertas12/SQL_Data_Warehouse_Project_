/*
-- ================================================================
						            Product Report
-- ================================================================
Purpose:
	- This report consolidates key product metrics and behaviors.
Highlights:
	1. Gathers essential fields such as product name, category, subcategory, and cost.
	2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
	3. Aggregates product-level metrics:
		-> total orders
		-> total sales
		-> total quantity sold
		-> total customers (unique)
		-> lifespan (in months)
	4. Calculates valuable KPIs:
		-> average selling price
		-> recency (months since last sale)
		-> average order revenue (AOR)
		-> average monthly revenue
-- ================================================================
*/
CREATE VIEW product_report AS
WITH base_query AS(
SELECT
	sls.order_number,
    sls.customer_key,
    sls.order_date,
    sls.sales_amount,
    sls.quantity,
    pr.product_key,
    pr.product_name,
    pr.category,
    pr.subcategory,
    pr.cost
FROM gold.fact_sales sls
LEFT JOIN gold.dim_products pr
ON sls.product_key=pr.product_key
WHERE sls.order_date IS NOT NULL
), product_aggregations AS(
SELECT
	product_key,
    product_name,
    category,
    subcategory,
    cost,
    COUNT(DISTINCT customer_key) AS total_customers,
    COUNT(DISTINCT order_number) AS total_orders,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    MAX(order_date) AS last_sale_date,
    TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
GROUP BY product_key, product_name, category, subcategory, cost
)
SELECT
	product_key,
    product_name,
    category,
    subcategory,
    cost,
    CASE
		WHEN total_sales<10000 THEN 'Low performer'
        WHEN total_sales>1000000 THEN 'High Performer'
        ELSE 'Medium Performer'
    END AS product_segment,
    last_sale_date,
    lifespan,
    TIMESTAMPDIFF(MONTH, last_sale_date, CURDATE()) AS recency_months,
    total_customers,
    total_orders,
    total_sales,
    total_quantity,
    -- Average Selling Price = Total Sales/Quantity Sold
    CASE
		WHEN total_quantity=0 THEN total_sales
		ELSE ROUND(total_sales/total_quantity) 
    END AS avg_selling_price,
    -- Average Order Revenue(AOR) = Total Sales/Total Orders
    CASE
		WHEN total_orders=0 THEN 0
		ELSE ROUND(total_sales/total_orders)
    END AS avg_order_revenue,
    -- Average Monthly Revenue = Total Sales/Lifespan
    CASE
		WHEN lifespan=0 THEN total_sales
        ELSE ROUND(total_sales/lifespan)
    END AS avg_monthly_revenue
FROM product_aggregations;

SELECT * FROM product_report;
