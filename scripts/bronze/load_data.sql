/*
-- -----------------------------------------------------------------------------------------------------------------
Loading data as it is into bronze layer tables

Script Purpose:
	This script loads the data from csv files to created tables in bronze layer.
	Since null values are by default stored as 0 in sql tables, this script ensures 
	that NULL and Blank values are stored as NULL itself in sql tables rather than 0(Same like in SQL Server).
	Since this is Bronze layer and data should be loaded as it is, this step is prioritized
-- -----------------------------------------------------------------------------------------------------------------
*/



-- -----------------------------------------------------------------------------------------------------------------
-- CRM Folder: crm_cust_info Table
-- -----------------------------------------------------------------------------------------------------------------
LOAD DATA LOCAL INFILE 'C:/Users/samee/OneDrive/Documents/MySQL/SQL Data Warehouse Project/sql-data-warehouse-project-main/sql-data-warehouse-project-main/datasets/source_crm/cust_info.csv'
INTO TABLE bronze.crm_cust_info
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
	@cst_id,
    @cst_key,
    @cst_firstname,
    @cst_lastname,
    @cst_marital_status,
    @cst_gndr,
    @cst_create_date
)
SET
    cst_id             = NULLIF(@cst_id, ''),
    cst_key			   =NULLIF(@cst_key, ''),
    cst_firstname      = NULLIF(@cst_firstname, ''),
    cst_lastname       = NULLIF(@cst_lastname, ''),
    cst_marital_status = NULLIF(@cst_marital_status, ''),
    cst_gndr           = NULLIF(@cst_gndr, ''),
    cst_create_date    = NULLIF(@cst_create_date, '');



-- -----------------------------------------------------------------------------------------------------------------
-- CRM Folder: crm_prd_info Table
-- -----------------------------------------------------------------------------------------------------------------
LOAD DATA LOCAL INFILE 'C:/Users/samee/OneDrive/Documents/MySQL/SQL Data Warehouse Project/sql-data-warehouse-project-main/sql-data-warehouse-project-main/datasets/source_crm/prd_info.csv'
INTO TABLE bronze.crm_prd_info
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    prd_id,
    prd_key,
    prd_nm,
    @prd_cost,
    @prd_line,
    prd_start_dt,
    @prd_end_dt
)
SET
    prd_id       = NULLIF(@prd_id, ''),
    prd_key      = NULLIF(@prd_key, ''),
    prd_nm       = NULLIF(@prd_nm, ''),
    prd_cost     = NULLIF(@prd_cost, ''),
    prd_line     = NULLIF(@prd_line, ''),
    prd_start_dt = NULLIF(@prd_start_dt, ''),
    prd_end_dt   = NULLIF(@prd_end_dt, '');



-- -----------------------------------------------------------------------------------------------------------------
-- CRM Folder: crm_sales_details Table
-- -----------------------------------------------------------------------------------------------------------------
LOAD DATA LOCAL INFILE 'C:/Users/samee/OneDrive/Documents/MySQL/SQL Data Warehouse Project/sql-data-warehouse-project-main/sql-data-warehouse-project-main/datasets/source_crm/sales_details.csv'
INTO TABLE bronze.crm_sales_details
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    @sls_ord_num,
    @sls_prd_key,
    @sls_cust_id,
    @sls_order_dt,
    @sls_ship_dt,
    @sls_due_dt,
    @sls_sales,
    @sls_quantity,
    @sls_price
)
SET
    sls_ord_num  = NULLIF(@sls_ord_num, ''),
    sls_prd_key  = NULLIF(@sls_prd_key, ''),
    sls_cust_id  = NULLIF(@sls_cust_id, ''),
    sls_order_dt = NULLIF(@sls_order_dt, ''),
    sls_ship_dt  = NULLIF(@sls_ship_dt, ''),
    sls_due_dt   = NULLIF(@sls_due_dt, ''),
    sls_sales    = NULLIF(@sls_sales, ''),
    sls_quantity = NULLIF(@sls_quantity, ''),
    sls_price    = NULLIF(@sls_price, '');



-- -----------------------------------------------------------------------------------------------------------------
-- ERP Folder: erp_cust_az12 Table
-- -----------------------------------------------------------------------------------------------------------------
LOAD DATA LOCAL INFILE 'C:/Users/samee/OneDrive/Documents/MySQL/SQL Data Warehouse Project/sql-data-warehouse-project-main/sql-data-warehouse-project-main/datasets/source_erp/CUST_AZ12.csv'
INTO TABLE bronze.erp_cust_az12
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    @cid,
    @bdate,
    @gen
)
SET
    cid   = NULLIF(@cid, ''),
    bdate = NULLIF(@bdate, ''),
    gen   = NULLIF(@gen, '');



-- -----------------------------------------------------------------------------------------------------------------
-- ERP Folder: erp_loc_a101 Table
-- -----------------------------------------------------------------------------------------------------------------
LOAD DATA LOCAL INFILE 'C:/Users/samee/OneDrive/Documents/MySQL/SQL Data Warehouse Project/sql-data-warehouse-project-main/sql-data-warehouse-project-main/datasets/source_erp/LOC_A101.csv'
INTO TABLE bronze.erp_loc_a101
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    @cid,
    @cntry
)
SET
    cid   = NULLIF(@cid, ''),
    cntry = NULLIF(@cntry, '');



-- -----------------------------------------------------------------------------------------------------------------
-- ERP Folder: erp_px_cat_g1v2 Table
-- -----------------------------------------------------------------------------------------------------------------
LOAD DATA LOCAL INFILE 'C:/Users/samee/OneDrive/Documents/MySQL/SQL Data Warehouse Project/sql-data-warehouse-project-main/sql-data-warehouse-project-main/datasets/source_erp/PX_CAT_G1V2.csv'
INTO TABLE bronze.erp_px_cat_g1v2
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    @id,
    @cat,
    @subcat,
    @maintenance
)
SET
    id          = NULLIF(@id, ''),
    cat         = NULLIF(@cat, ''),
    subcat      = NULLIF(@subcat, ''),
    maintenance = NULLIF(@maintenance, '');
