use datawarehouse; --use database
/*=========================================================
            LOADING SILVER LAYER
=========================================================*/
/*=========================================================
1. Load CRM tables
=========================================================*/
DROP PROCEDURE IF EXISTS LoadSilverLayerData;

DELIMITER $$

CREATE PROCEDURE LoadSilverLayerData()
BEGIN
SET @batch_start_time = NOW();

SELECT '==========================================' AS Status;
SELECT 'Loading Silver Layer Started' AS Status;
SELECT '==========================================' AS Status;


-- Start Time
SET @start_time = NOW();
TRUNCATE TABLE silver_crm_cust_info;
INSERT INTO silver_crm_cust_info
(
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
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'n/a'
    END AS cst_marital_status,

    CASE
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'n/a'
    END AS cst_gndr,

    cst_create_date

FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY cst_id
            ORDER BY cst_create_date DESC
        ) AS flag_last
    FROM datawarehouse.bronze_crm_cust_info
    WHERE cst_id IS NOT NULL
      AND TRIM(cst_id) <> ''
) t

WHERE flag_last = 1;

-- End Time
SET @end_time = NOW();

SELECT CONCAT(
    '>> Load Duration: ',
    TIMESTAMPDIFF(SECOND, @start_time, @end_time),
    ' seconds'
) AS Load_Duration;

SELECT '>> -----------------------------' AS Status;
            

/*=========================================================
    SILVER LAYER - CRM SALES DETAILS
=========================================================*/ 
 
-- Start Time
SET @start_time = NOW();
truncate table silver_crm_sales_details;
INSERT INTO silver_crm_sales_details
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
)

SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,

    CASE
        WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt) <> 8 THEN NULL
        ELSE STR_TO_DATE(sls_order_dt,'%Y%m%d')
    END AS sls_order_dt,

    CASE
        WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt) <> 8 THEN NULL
        ELSE STR_TO_DATE(sls_ship_dt,'%Y%m%d')
    END AS sls_ship_dt,

    CASE
        WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt) <> 8 THEN NULL
        ELSE STR_TO_DATE(sls_due_dt,'%Y%m%d')
    END AS sls_due_dt,

    CASE
    WHEN sls_sales IS NULL OR sls_sales <= 0 THEN
        sls_quantity * ABS(sls_price)
    ELSE
        sls_sales

    END AS sls_sales,

    sls_quantity,

  CASE
    WHEN sls_price IS NULL OR sls_price <= 0 THEN
        sls_sales / NULLIF(sls_quantity,0)
    ELSE
        sls_price
END AS sls_price

FROM datawarehouse.bronze_crm_sales_details;

-- End Time
SET @end_time = NOW();

SELECT CONCAT(
    '>> Load Duration: ',
    TIMESTAMPDIFF(SECOND,@start_time,@end_time),
    ' seconds'
) AS Load_Duration;

SELECT '>> -----------------------------' AS Status;


/*=========================================================
            LOAD SILVER CRM PRODUCT INFO
=========================================================*/

SET @start_time = NOW();

TRUNCATE TABLE silver_crm_prd_info;

INSERT INTO silver_crm_prd_info
(
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

    SUBSTRING(prd_key, 7) AS prd_key,

    prd_nm,

    IFNULL(prd_cost, 0) AS prd_cost,

    CASE
        WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
        WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
        WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
        WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
        ELSE 'n/a'
    END AS prd_line,

    DATE(prd_start_dt) AS prd_start_dt,

    DATE_SUB(
        LEAD(prd_start_dt) OVER (
            PARTITION BY prd_key
            ORDER BY prd_start_dt
        ),
        INTERVAL 1 DAY
    ) AS prd_end_dt

FROM datawarehouse.bronze_crm_prd_info;
SET @end_time = NOW();

/*=========================================================
                LOADING ERP TABLES
=========================================================*/

SELECT '------------------------------------------------' AS Status;
SELECT 'Loading ERP Tables' AS Status;
SELECT '------------------------------------------------' AS Status;


-- =========================================
-- Loading erp_cust_az12
-- =========================================

INSERT INTO silver_erp_cust_az12
(
    CID,
    BDATE,
    GEN
)

SELECT
    CID,
    BDATE,
    GEN
FROM datawarehouse.bronze_erp_cust_az12;

-- =========================================
-- Loading erp_px_cat_g1v2
-- =========================================

SET @start_time = NOW();

TRUNCATE TABLE silver_erp_px_cat_g1v2;

INSERT INTO silver_erp_px_cat_g1v2
(
    id,
    cat,
    subcat,
    maintenance
)

SELECT
    id,
    cat,
    subcat,
    maintenance

FROM datawarehouse.bronze_erp_px_cat_g1v2;

SET @end_time = NOW();

SELECT CONCAT(
    '>> Load Duration: ',
    TIMESTAMPDIFF(SECOND,@start_time,@end_time),
    ' seconds'
) AS Load_Duration;

SELECT '>> -----------------------------' AS Status;

SELECT '==========================================' AS Status;




-- =========================================
-- Loading erp_loc_a101
-- =========================================

SET @start_time = NOW();

TRUNCATE TABLE silver_erp_loc_a101;

INSERT INTO silver_erp_loc_a101
(
    cid,
    cntry
)

SELECT
    REPLACE(cid, '-', '') AS cid,

    CASE
        WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
        WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
        ELSE TRIM(cntry)
    END AS cntry

FROM datawarehouse.bronze_erp_loc_a101;

SET @end_time = NOW();

SELECT CONCAT(
    '>> Load Duration: ',
    TIMESTAMPDIFF(SECOND,@start_time,@end_time),
    ' seconds'
) AS Load_Duration;

-- =========================================
-- Batch End
-- =========================================

SET @batch_end_time = NOW();

SELECT '==========================================' AS Status;
SELECT 'Loading Silver Layer is Completed' AS Status;

SELECT CONCAT(
    'Total Load Duration: ',
    TIMESTAMPDIFF(SECOND,@batch_start_time,@batch_end_time),
    ' seconds'
) AS Total_Load_Duration;

SELECT 'Loading succesfull>>>>>>>>>>>>>>>>' AS Status;

END$$

DELIMITER ;
 
