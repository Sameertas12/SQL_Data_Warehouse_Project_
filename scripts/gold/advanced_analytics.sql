/*
================================================================
================================================================
   					     ADVANCED ANALYTICS
================================================================
================================================================
*/


-- ================================================================
/*
Change Over Time Analysis(Trends)
	-> Analyses how a measure evolves over time
    -> Helps track trends and identify seasonality in your data
    Formula: [Measure] by [Date Dimension]
    Ex: Total Sales by year, Average cost by month
*/
-- ================================================================

-- Analyze sales performance over time
SELECT
	YEAR(order_Date) AS order_year,
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_Date)
ORDER BY order_year;


-- ================================================================
/*
Cummulative Analysis
	-> Aggregate the data progressively over time
    -> Helps to understand whether the business is growing or declining
    Formula: [Cummulative Measure] by [Date Dimension]
    Ex: Running Total of Sales by Year, Moving Average of sales by month
*/
-- ================================================================

-- Calculate the total sales per month and the running total of sales over time
SELECT
	order_month,
    total_sales,
    SUM(total_sales) OVER(PARTITION BY sales_year ORDER BY order_month) AS running_total_sales
    -- Default Window Frame: ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
FROM(
	SELECT
		YEAR(order_date) AS sales_year,		-- Further used to calculate running total resetting per year
		DATE_FORMAT(order_date, '%Y-%m') AS order_month,
		SUM(sales_amount) AS total_sales
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY YEAR(order_date), DATE_FORMAT(order_date, '%Y-%m')
) t
ORDER BY order_month;

-- Calculate the average price per month and the mpving average of price over time
SELECT
	order_month,
    average_price,
    ROUND(AVG(average_price) OVER(PARTITION BY order_year ORDER BY order_month)) AS moving_avg_price
FROM(
	SELECT
		YEAR(order_date) AS order_year,
		DATE_FORMAT(order_date, '%Y-%m') AS order_month,
		ROUND(AVG(COALESCE(price,0))) AS average_price
	FROM gold.fact_sales
    WHERE order_date IS NOT NULL
	GROUP BY YEAR(order_date), DATE_FORMAT(order_date, '%Y-%m')
) t
ORDER BY order_month;


-- ================================================================
/*
Performance Analysis
	-> Comparing the current value to a target value
    -> Helps measure success and compare performance
    Formula: [Current Measure] - [Target Measure]
    Ex: Current Sales-Avg Sales, Current year sales-Previous year sales, Current sales-lowest sales
*/
-- ================================================================

-- Analyze the yearly performance of products by comparing each product's sales to both its 
-- average sales performance and the previous year's sales(YOY - Year over Year Analysis)
WITH yearly_product_sales AS(
SELECT
	YEAR(sls.order_date) AS order_year,
    pr.product_name,
    SUM(sls.sales_amount) AS current_sales
FROM gold.fact_sales sls
LEFT JOIN gold.dim_products pr
ON sls.product_key=pr.product_key
WHERE order_date IS NOT NULL
GROUP BY YEAR(sls.order_date), pr.product_name
ORDER BY pr.product_name, YEAR(sls.order_date)
)
SELECT
	order_year,
    product_name,
    current_sales,
    ROUND(AVG(current_sales) OVER(PARTITION BY product_name)) AS avg_sales,
    current_sales - ROUND(AVG(current_sales) OVER(PARTITION BY product_name)) AS diff_avg_sales,
    CASE
		WHEN current_sales - ROUND(AVG(current_sales) OVER(PARTITION BY product_name)) > 0 THEN 'Above Average'
        WHEN current_sales - ROUND(AVG(current_sales) OVER(PARTITION BY product_name)) < 0 THEN 'Below Average'
        ELSE 'Average'
    END AS avg_change,
    LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS previous_year_sales,
    current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS diff_py_sales,
    CASE
		WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase in Sales'
        WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease in Sales'
        ELSE 'No Change in Sales'
    END AS py_sales_change
FROM yearly_product_sales;


-- ================================================================
/*
Part-To-Whole Analysis(Proportional Analysis)
	-> Analyze how an individual part is performing compared to overall
    -> Allows us to understand which category has the greatest impact on business
    Formula: ([Measure]/Total[Measure])*100 by [Dimension]
    Ex: (Sales/Total Sales) * 100 By Category
*/
-- ================================================================

-- Which categories contribute the most to overall sales?
WITH category_sales AS(
SELECT
	pr.category,
    SUM(sls.sales_amount) AS total_sales
FROM gold.fact_sales sls
LEFT JOIN gold.dim_products pr
ON sls.product_key=pr.product_key
GROUP BY pr.category
)
SELECT
	category,
    total_sales,
    SUM(total_sales) OVER() AS overall_sales,
    CONCAT(ROUND((total_sales/SUM(total_sales) OVER())*100, 2), '%') AS percentage_of_total
FROM category_sales;


-- ================================================================
/*
Data Segmentation
	-> Group the data based on a specific range
    -> Helps understand the correlation between two measures
    Formula: [Measure] by [Measure]
    Ex: Total products by sales range, Total customers by age
*/
-- ================================================================

-- Segment products into cost ranges and count how many products fall into each segment
WITH cost_ranges AS(
SELECT
	product_key,
    product_name,
    cost,
	CASE
		WHEN cost<100 THEN 'Below 100'
        WHEN cost BETWEEN 100 AND 500 THEN '100-500'
        WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
        ELSE 'Above 1000'
    END AS cost_range
FROM gold.dim_products
)
SELECT
	cost_range,
    COUNT(product_key) AS total_products
FROM cost_ranges
GROUP BY cost_range
ORDER BY total_products DESC;

/*
Group customers into three segments based in their spending behaviour:
	- VIP: Customers with atleast 12 months of history and spending more than 5000.
	- Regular: Customers with atleast 12 months of history and spending 5000 or less.
	- New: Customers with a lifespan of less than 12 months.
Also find total number of customers by each group.
*/
WITH customer_lifespan AS(
SELECT
	cu.customer_key,
    SUM(sls.sales_amount) AS total_sales,
    MIN(sls.order_date) AS first_order,
    MAX(sls.order_date) AS last_order,
    TIMESTAMPDIFF(MONTH, MIN(sls.order_date), MAX(sls.order_date)) AS lifespan
FROM gold.fact_sales sls
LEFT JOIN gold.dim_customers cu
ON sls.customer_key=cu.customer_key
GROUP BY cu.customer_key
),
customer_segmentation AS(
SELECT
	customer_key,
	CASE
		WHEN lifespan>=12 AND total_sales>5000 THEN 'VIP'
		WHEN lifespan>=12 AND total_sales<=5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment
FROM customer_lifespan
)
SELECT
	customer_segment,
    COUNT(customer_key) AS total_customers
FROM customer_segmentation
GROUP BY customer_segment
ORDER BY total_customers DESC;
