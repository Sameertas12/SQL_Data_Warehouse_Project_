-- Loading Data as it is into bronze layer tables
LOAD DATA LOCAL INFILE 'C:/Users/samee/OneDrive/Documents/MySQL/SQL Data Warehouse Project/sql-data-warehouse-project-main/sql-data-warehouse-project-main/datasets/source_crm/cust_info.csv'
INTO TABLE bronze.crm_cust_info
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/samee/OneDrive/Documents/MySQL/SQL Data Warehouse Project/sql-data-warehouse-project-main/sql-data-warehouse-project-main/datasets/source_crm/prd_info.csv'
INTO TABLE bronze.crm_prd_info
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/samee/OneDrive/Documents/MySQL/SQL Data Warehouse Project/sql-data-warehouse-project-main/sql-data-warehouse-project-main/datasets/source_crm/sales_details.csv'
INTO TABLE bronze.crm_sales_details
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/samee/OneDrive/Documents/MySQL/SQL Data Warehouse Project/sql-data-warehouse-project-main/sql-data-warehouse-project-main/datasets/source_erp/CUST_AZ12.csv'
INTO TABLE bronze.erp_CUST_AZ12
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/samee/OneDrive/Documents/MySQL/SQL Data Warehouse Project/sql-data-warehouse-project-main/sql-data-warehouse-project-main/datasets/source_erp/LOC_A101.csv'
INTO TABLE bronze.erp_loc_a101
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/samee/OneDrive/Documents/MySQL/SQL Data Warehouse Project/sql-data-warehouse-project-main/sql-data-warehouse-project-main/datasets/source_erp/PX_CAT_G1V2.csv'
INTO TABLE bronze.erp_px_cat_g1v2
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
