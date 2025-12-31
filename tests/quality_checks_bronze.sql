-- ---------------------------------------------------------------
-- Table: crm_cust_info
-- ---------------------------------------------------------------

-- Checking for Nulls or Duplicates in Primary key column
SELECT
	cst_id,
    COUNT(*) AS Cnt
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING(Cnt>1) OR cst_id IS NULL;

-- Check for unwanted spaces in cst_firstname and cst_lastname columns
SELECT
	cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname!=TRIM(cst_firstname);

SELECT
	cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname!=TRIM(cst_lastname);

-- Check data consistency in gender and marital status column
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;

SELECT DISTINCT cst_marital_status
FROM bronze.crm_cust_info;

-- As we inserted cst_create_date values into a date column,
-- no cleaning is needed. And as we ignored null values in cst_id while inserting
-- No problem's present in this column.
SELECT
	*
FROM bronze.crm_cust_info
WHERE YEAR(dwh_create_date)=0;


-- ---------------------------------------------------------------
-- Table: crm_prd_info
-- ---------------------------------------------------------------

-- Checking for Nulls or Duplicates in Primary key column
SELECT
	prd_id,
    COUNT(*) AS Cnt
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING(Cnt>1) OR prd_id IS NULL;

-- prd_key column should be modified. Extract first 5 characters to get cat_id
-- Also replace '-' with '_' in extracted cat_id

-- Check for unwanted spaces in prd_nm column
SELECT
	prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm!=TRIM(prd_nm);

-- Check for nulls or negative values in prd_cost column
SELECT
	prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost<0;

-- Check data consistency in gender and marital status column 
SELECT
	DISTINCT prd_line
FROM bronze.crm_prd_info;

-- Check for NULL values in prd_start_dt column
SELECT *
FROM bronze.crm_prd_info
WHERE prd_start_dt IS NULL;

-- Check for invalid date order(prd_end_dt should not be earlier than prd_start_dt)
SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt<prd_start_dt;


-- ---------------------------------------------------------------
-- Table: crm_sales_details
-- ---------------------------------------------------------------
SELECT * FROM bronze.crm_sales_details;

-- Check for unwanted extra spaces in sls_ord_num and sls_prd_key column
SELECT *
FROM bronze.crm_sales_details
WHERE sls_ord_num!=TRIM(sls_ord_num);

-- Check for any values that are in sls_prd_key and not in 
-- prd_key of crm_prd_info table in silver layer
SELECT * FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN(SELECT prd_key FROM silver.crm_prd_info);

-- Similarly Check for any values that are in sls_cust_id and not in 
-- cst_id of crm_cust_info table in silver layer
SELECT * FROM bronze.crm_sales_details 
WHERE sls_cust_id NOT IN(SELECT cst_id FROM silver.crm_cust_info);

-- sls_order_dt column is actually date that is in INT format
-- Check for any values <= 0 and whose length is != 8
SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt<=0 OR LENGTH(sls_order_dt)!=8;

-- Check for dates orders
SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt>sls_ship_dt OR sls_order_dt>sls_due_dt;

-- Check for negative and NULL values in sls_sales, sls_quantity and sls_price
-- Also check for rows where sales != quantity * price
SELECT
	sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity*sls_price
OR sls_sales<=0 OR sls_quantity<=0 OR sls_price<=0
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
ORDER BY sls_sales, sls_quantity, sls_price;
/*
	Data is inconsistent in sls_sales and sls_price columns. Needs to be fixed.
*/


-- ---------------------------------------------------------------
-- Table: erp_cust_az12
-- ---------------------------------------------------------------
SELECT * FROM bronze.erp_cust_az12;

-- There are some extra characters at the beginning(NAS) in cid column.
-- Remove those unwanted data.

-- Check for values in bdate whether they are from future that is after todays date
SELECT * FROM bronze.erp_cust_az12 WHERE bdate>CURDATE();

-- Check for data consistency in gen column
-- There are hidden spaces(\r, \n, \t) in gen column which cant be determined by TRIM()
-- Fix this and make data consistent
SELECT DISTINCT gen
FROM bronze.erp_cust_az12;


-- ---------------------------------------------------------------
-- Table: erp_loc_a101
-- ---------------------------------------------------------------
SELECT * FROM bronze.erp_loc_a101;

-- Clean the extra '-' in cid column.

-- Standardize the data in cntry column
SELECT DISTINCT cntry
FROM bronze.erp_loc_a101;


-- ---------------------------------------------------------------
-- Table: erp_px_cat_g1v2
-- ---------------------------------------------------------------
SELECT * FROM bronze.erp_px_cat_g1v2;

-- id column is good enough

-- Check for unwanted spaces in cat, subcat and maintenance columns
SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE cat!=TRIM(cat) OR subcat!=TRIM(subcat) OR maintenance!=TRIM(maintenance);

-- Check whether the data in cat and subcat columns are consistent
SELECT DISTINCT cat
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT subcat
FROM bronze.erp_px_cat_g1v2;

-- Check whether the data in maintainance column is consistent
SELECT 
	DISTINCT maintenance,
    LENGTH(maintenance)
FROM bronze.erp_px_cat_g1v2
