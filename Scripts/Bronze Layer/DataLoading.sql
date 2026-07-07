/*=========================================================
 Project     : SQL Data Warehouse Project (MySQL)
 Layer       : Bronze
 Purpose     : Load raw CRM and ERP source files into
               Bronze tables without transformation.

 Author      : Maram VijayReddy
 Date        : 2026-07-05
=========================================================*/

/*=========================================
  CRM TABLES
=========================================*/
SET @overall_start = NOW(6);

SELECT '=========================================' AS '';
SELECT 'STARTING BRONZE LAYER LOAD' AS Status;

SELECT '=========================================' AS '';
select "LOADING CRM TABLES:" as statusofcrmtables;
SELECT 'Loading bronze_crm_cust_info...' AS Status;
SET @crm_cust_start = NOW(6);
SET @execution_id = UUID();
TRUNCATE TABLE bronze_crm_cust_info;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cust_info.csv'
INTO TABLE bronze_crm_cust_info
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    @cst_marital_status,
    @cst_gndr,
    @cst_create_date
)
SET
    cst_marital_status = NULLIF(TRIM(@cst_marital_status), ''),
    cst_gndr = NULLIF(TRIM(@cst_gndr), ''),
    cst_create_date = NULLIF(TRIM(@cst_create_date), '');
 SET @crm_cust_end = NOW(6);   
 
INSERT INTO etl_execution_log
(
 execution_id,
layer,
table_name,
start_time,
end_time,
duration_seconds,
rows_loaded,
status,
message
)
VALUES
( @execution_id,
'Bronze',
'bronze_crm_cust_info',
@crm_cust_start,
@crm_cust_end,

ROUND(
TIMESTAMPDIFF(
MICROSECOND,
@crm_cust_start,
@crm_cust_end
)/1000000,
3
),

(
SELECT COUNT(*)
FROM bronze_crm_cust_info
),

'SUCCESS',

'Customer Information Loaded Successfully'
);   

SELECT 'Loading bronze_crm_prd_info...' AS Status;
TRUNCATE TABLE bronze_crm_prd_info;
SET @crm_prd_start = NOW(6);
SET @execution_id = UUID();
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/prd_info.csv'
INTO TABLE bronze_crm_prd_info
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    prd_id,
    prd_key,
    prd_nm,
    @prd_cost,
    prd_line,
    @prd_start_dt,
    @prd_end_dt
)
SET
    prd_cost = NULLIF(TRIM(@prd_cost), ''),
    prd_start_dt = NULLIF(TRIM(@prd_start_dt), ''),
    prd_end_dt = NULLIF(TRIM(@prd_end_dt), '');
SET @crm_prd_end = NOW(6);
INSERT INTO etl_execution_log
(  execution_id,
    layer,
    table_name,
    start_time,
    end_time,
    duration_seconds,
    rows_loaded,
    status,
    message
)
VALUES
( @execution_id,
    'Bronze',
    'bronze_crm_prd_info',
    @crm_prd_start,
    @crm_prd_end,
    ROUND(TIMESTAMPDIFF(MICROSECOND,@crm_prd_start,@crm_prd_end)/1000000,3),
    (SELECT COUNT(*) FROM bronze_crm_prd_info),
    'SUCCESS',
    'Product Information Loaded Successfully'
);    
    
SELECT 'Loading bronze_crm_sales_details...' AS Status;
TRUNCATE TABLE bronze_crm_sales_details;
SET @crm_sales_start = NOW(6);
SET @execution_id = UUID();
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales_details.csv'
INTO TABLE bronze_crm_sales_details
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
);
SET @crm_sales_end = NOW(6);
INSERT INTO etl_execution_log
(   execution_id,
    layer,
    table_name,
    start_time,
    end_time,
    duration_seconds,
    rows_loaded,
    status,
    message
)
VALUES
(@execution_id,
     'Bronze',
    'bronze_crm_sales_details',
    @crm_sales_start,
    @crm_sales_end,
    ROUND(TIMESTAMPDIFF(MICROSECOND,@crm_sales_start,@crm_sales_end)/1000000,3),
    (SELECT COUNT(*) FROM bronze_crm_sales_details),
    'SUCCESS',
    'Sales Details Loaded Successfully'
);


SELECT COUNT(*) AS Total_Rows
FROM bronze_crm_sales_details;


/*=========================================
  ERP TABLES
=========================================*/
select "Loading ERP TABLES...." as statusoferptables;
select "----------------------------------------------------";
select "Loading Bronze_erp_cust_az12 table.." as status;
SET @erp_cust_start = NOW(6);
SET @execution_id = UUID();

TRUNCATE TABLE bronze_erp_cust_az12;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CUST_AZ12.csv'
INTO TABLE bronze_erp_cust_az12
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(CID, BDATE, @GEN)
SET
    GEN = NULLIF(TRIM(@GEN), '');

SELECT COUNT(*) FROM bronze_erp_cust_az12;
SET @erp_cust_end = NOW(6);
INSERT INTO etl_execution_log
( execution_id,
    layer,
    table_name,
    start_time,
    end_time,
    duration_seconds,
    rows_loaded,
    status,
    message
)
VALUES
(@execution_id,
    'Bronze',
    'bronze_erp_cust_az12',
    @erp_cust_start,
    @erp_cust_end,
    ROUND(TIMESTAMPDIFF(MICROSECOND,@erp_cust_start,@erp_cust_end)/1000000,3),
    (SELECT COUNT(*) FROM bronze_erp_cust_az12),
    'SUCCESS',
    'ERP Customer Information Loaded Successfully'
);
-- ----------------------------------------------------------
select "Loading bronze_erp_loc_a101 table.." as status;
-- Step 1: Clear existing data
TRUNCATE TABLE bronze_erp_loc_a101;
SET @erp_loc_start = NOW(6);
SET @execution_id = UUID();
-- Step 2: Import the CSV

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/LOC_A101.csv'
INTO TABLE bronze_erp_loc_a101
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(CID, @CNTRY)
SET
    CNTRY = NULLIF(TRIM(@CNTRY), '');

-- Step 3: Verify the import
SELECT COUNT(*) AS Total_Rows
FROM bronze_erp_loc_a101;
SET @erp_loc_end = NOW(6);
INSERT INTO etl_execution_log
( execution_id,
    layer,
    table_name,
    start_time,
    end_time,
    duration_seconds,
    rows_loaded,
    status,
    message
)
VALUES
(@execution_id,
    'Bronze',
    'bronze_erp_loc_a101',
    @erp_loc_start,
    @erp_loc_end,
    ROUND(TIMESTAMPDIFF(MICROSECOND,@erp_loc_start,@erp_loc_end)/1000000,3),
    (SELECT COUNT(*) FROM bronze_erp_loc_a101),
    'SUCCESS',
    'ERP Location Information Loaded Successfully'
);




-- ---------------------------------------------------------

select "Loading bronze_erp_px_cat_g1v2 ..." as status;
-- Step 1: Clear existing data
TRUNCATE TABLE bronze_erp_px_cat_g1v2;
SET @erp_px_start = NOW(6);
SET @execution_id = UUID();
-- Step 2: Import the CSV
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/PX_CAT_G1V2.csv'
INTO TABLE bronze_erp_px_cat_g1v2
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(ID, @CAT, @SUBCAT, @MAINTENANCE)
SET
    CAT = NULLIF(TRIM(@CAT), ''),
    SUBCAT = NULLIF(TRIM(@SUBCAT), ''),
    MAINTENANCE = NULLIF(TRIM(@MAINTENANCE), '');

-- Step 3: Verify the import
SELECT COUNT(*) AS Total_Rows
FROM bronze_erp_px_cat_g1v2;

SET @erp_px_end = NOW(6);
 select now() as endtime;
 
 SET @overall_end = NOW(6);
INSERT INTO etl_execution_log
( execution_id,
    layer,
    table_name,
    start_time,
    end_time,
    duration_seconds,
    rows_loaded,
    status,
    message
)
VALUES
(@execution_id,
    'Bronze',
    'bronze_erp_px_cat_g1v2',
    @erp_px_start,
    @erp_px_end,
    ROUND(TIMESTAMPDIFF(MICROSECOND,@erp_px_start,@erp_px_end)/1000000,3),
    (SELECT COUNT(*) FROM bronze_erp_px_cat_g1v2),
    'SUCCESS',
    'ERP Product Category Loaded Successfully'
);
set @overall_end=now(6);

/*=====================================================
                VERIFICATION
===================================================== */
SELECT
'bronze_crm_cust_info' AS Table_Name,
COUNT(*) AS Rows_Loaded,
ROUND(TIMESTAMPDIFF(MICROSECOND,@crm_cust_start,@crm_cust_end)/1000000,3) AS Time_Seconds
FROM bronze_crm_cust_info

UNION ALL

SELECT
'bronze_crm_prd_info',
COUNT(*),
ROUND(TIMESTAMPDIFF(MICROSECOND,@crm_prd_start,@crm_prd_end)/1000000,3)
FROM bronze_crm_prd_info

UNION ALL

SELECT
'bronze_crm_sales_details',
COUNT(*),
ROUND(TIMESTAMPDIFF(MICROSECOND,@crm_sales_start,@crm_sales_end)/1000000,3)
FROM bronze_crm_sales_details

UNION ALL

SELECT
'bronze_erp_cust_az12',
COUNT(*),
ROUND(TIMESTAMPDIFF(MICROSECOND,@erp_cust_start,@erp_cust_end)/1000000,3)
FROM bronze_erp_cust_az12

UNION ALL

SELECT
'bronze_erp_loc_a101',
COUNT(*),
ROUND(TIMESTAMPDIFF(MICROSECOND,@erp_loc_start,@erp_loc_end)/1000000,3)
FROM bronze_erp_loc_a101

UNION ALL
select
'bronze_erp_px_cat_g1v2',
COUNT(*),
ROUND(TIMESTAMPDIFF(MICROSECOND,@erp_px_start,@erp_px_end)/1000000,3)
FROM bronze_erp_px_cat_g1v2;