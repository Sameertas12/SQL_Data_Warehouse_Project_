-- Inserting cleaned data into silver layer

-- ---------------------------------------------------------------
-- Table: crm_cust_info 
-- ---------------------------------------------------------------
INSERT INTO silver.crm_cust_info(
	cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
)
SELECT
	cst_id,
	cst_key,
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_lastname) AS cst_lastname,
	CASE
		WHEN UPPER(TRIM(cst_marital_status))='M' THEN 'Married'
		WHEN UPPER(TRIM(cst_marital_status))='S' THEN 'Single'
		ELSE 'n/a'
	END AS cst_marital_status,
	CASE
		WHEN UPPER(TRIM(cst_gndr))='M' THEN 'Male'
		WHEN UPPER(TRIM(cst_gndr))='F' THEN 'Female'
		ELSE 'n/a'
	END AS cst_gndr,
	cst_create_date
FROM(
	SELECT
		*,
		ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
	FROM bronze.crm_cust_info
	WHERE cst_id IS NOT NULL
) AS t
WHERE flag_last=1;


-- ---------------------------------------------------------------
-- Table: crm_prd_info
-- ---------------------------------------------------------------
INSERT INTO silver.crm_prd_info(
	prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
SELECT
	prd_id,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,
    prd_nm,
    COALESCE(prd_cost, 0) AS prd_cost,
    CASE UPPER(TRIM(prd_line))
		WHEN 'M' THEN 'Mountain'
        WHEN 'R' THEN 'Road'
        WHEN 'S' THEN 'Other sales'
        WHEN 'T' THEN 'Touring'
        ELSE 'n/a'
    END AS prd_line,
    CAST(prd_start_dt AS DATE),
    CAST(DATE_SUB(LEAD(prd_start_dt) OVER(
		PARTITION BY prd_key
        ORDER BY prd_start_dt
    ),  INTERVAL 1 DAY) AS DATE) AS prd_end_dt
FROM bronze.crm_prd_info;


-- ---------------------------------------------------------------
-- Table: crm_prd_info
-- ---------------------------------------------------------------
INSERT INTO silver.crm_sales_details(
	sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)
SELECT
	sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    CASE
		WHEN sls_order_dt<=0 OR LENGTH(sls_order_dt)!=8 THEN NULL
        ELSE STR_TO_DATE(sls_order_dt, '%Y%m%d')
    END AS sls_order_dt,
    CASE
		WHEN sls_ship_dt<=0 OR LENGTH(sls_ship_dt)!=8 THEN NULL
        ELSE STR_TO_DATE(sls_ship_dt, '%Y%m%d')
    END AS sls_ship_dt,
    CASE
		WHEN sls_due_dt<=0 OR LENGTH(sls_due_dt)!=8 THEN NULL
        ELSE STR_TO_DATE(sls_due_dt, '%Y%m%d')
    END AS sls_due_dt,
    CASE
		WHEN sls_sales<=0 OR 
			 sls_sales IS NULL OR 
             sls_sales != sls_quantity*ABS(sls_price) 
		THEN sls_quantity*ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,
    sls_quantity,
    CASE
		WHEN sls_price<=0 OR sls_price IS NULL THEN sls_sales/sls_quantity
        ELSE sls_price
    END AS sls_price
FROM bronze.crm_sales_details;


-- ---------------------------------------------------------------
-- Table: erp_cust_az12
-- ---------------------------------------------------------------
INSERT INTO silver.erp_cust_az12(
	cid,
    bdate,
    gen
)
SELECT
    CASE
		WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
        ELSE cid
    END AS cid,
    CASE
		WHEN bdate>CURDATE() THEN NULL
        ELSE bdate
    END AS bdate,
    CASE
		WHEN UPPER(REGEXP_REPLACE(gen, '[^A-Za-z]', '')) IN('M', 'MALE') THEN 'Male'
        WHEN UPPER(REGEXP_REPLACE(gen, '[^A-Za-z]', '')) IN('F', 'FEMALE') THEN 'Female'
        ELSE 'n/a'
    END AS gen
FROM bronze.erp_cust_az12;


-- ---------------------------------------------------------------
-- Table: erp_loc_a101
-- ---------------------------------------------------------------
INSERT INTO silver.erp_loc_a101(
	cid,
    cntry
)
SELECT
    REPLACE(cid, '-', '') as cid,
    CASE
		WHEN UPPER(REGEXP_REPLACE(cntry, '[^A-Za-z]', '')) IN('US', 'USA', 'UNITEDSTATES') THEN 'United States'
        WHEN UPPER(REGEXP_REPLACE(cntry, '[^A-Za-z]', '')) IN('DE', 'GERMANY') THEN 'Germany'
        WHEN REGEXP_REPLACE(cntry, '[^A-Za-z]', '') IS NULL OR REGEXP_REPLACE(cntry, '[^A-Za-z]', '')='' THEN 'n/a'
        ELSE cntry
    END AS cntry
FROM bronze.erp_loc_a101;


-- ---------------------------------------------------------------
-- Table: erp_px_cat_g1v2
-- ---------------------------------------------------------------
INSERT INTO silver.erp_px_cat_g1v2(
	id,
    cat,
    subcat,
    maintenance
)
SELECT
	id,
    cat,
    subcat,
    CASE
		WHEN REGEXP_REPLACE(maintenance, '[^A-Za-z]', '')='Yes' THEN 'Yes'
        WHEN REGEXP_REPLACE(maintenance, '[^A-Za-z]', '')='No' THEN 'No'
        ELSE 'n/a'
    END AS maintenance
FROM bronze.erp_px_cat_g1v2;
