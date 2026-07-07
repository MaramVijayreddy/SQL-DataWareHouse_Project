/*=========================================================
 Project     : SQL Data Warehouse Project (MySQL)
 Layer       : Bronze
 Purpose     : Create Bronze Layer Tables
 Author      : Maram VijayReddy
=========================================================*/

-- =====================================================
-- Drop Existing Bronze Tables
-- =====================================================
use datawarehouse;
DROP TABLE IF EXISTS bronze_crm_cust_info;
DROP TABLE IF EXISTS bronze_crm_prd_info;
DROP TABLE IF EXISTS bronze_crm_sales_details;
DROP TABLE IF EXISTS bronze_erp_cust_az12;
DROP TABLE IF EXISTS bronze_erp_loc_a101;
DROP TABLE IF EXISTS bronze_erp_px_cat_g1v2;

-- =====================================================
-- Create CRM Customer Information Table
-- =====================================================

CREATE TABLE bronze_crm_cust_info
(
    cst_id              VARCHAR(20),
    cst_key             VARCHAR(50),
    cst_firstname       VARCHAR(50),
    cst_lastname        VARCHAR(50),
    cst_marital_status  VARCHAR(20),
    cst_gndr            VARCHAR(20),
    cst_create_date     VARCHAR(20)
);

-- =====================================================
-- Create CRM Product Information Table
-- =====================================================

CREATE TABLE bronze_crm_prd_info
(
    prd_id          VARCHAR(20),
    prd_key         VARCHAR(50),
    prd_nm          VARCHAR(100),
    prd_cost        VARCHAR(20),
    prd_line        VARCHAR(50),
    prd_start_dt    VARCHAR(20),
    prd_end_dt      VARCHAR(20)
);

-- =====================================================
-- Create CRM Sales Details Table
-- =====================================================

CREATE TABLE bronze_crm_sales_details
(
    sls_ord_num     VARCHAR(20),
    sls_prd_key     VARCHAR(20),
    sls_cust_id     VARCHAR(20),
    sls_order_dt    VARCHAR(20),
    sls_ship_dt     VARCHAR(20),
    sls_due_dt      VARCHAR(20),
    sls_sales       VARCHAR(20),
    sls_quantity    VARCHAR(20),
    sls_price       VARCHAR(20)
);

-- =====================================================
-- Create ERP Customer Information Table
-- =====================================================

CREATE TABLE bronze_erp_cust_az12
(
    CID         VARCHAR(20),
    BDATE       VARCHAR(20),
    GEN         VARCHAR(20)
);

-- =====================================================
-- Create ERP Location Table
-- =====================================================

CREATE TABLE bronze_erp_loc_a101
(
    CID         VARCHAR(20),
    CNTRY       VARCHAR(50)
);

-- =====================================================
-- Create ERP Product Category Table
-- =====================================================

CREATE TABLE bronze_erp_px_cat_g1v2
(
    ID              VARCHAR(20),
    CAT             VARCHAR(50),
    SUBCAT          VARCHAR(50),
    MAINTENANCE     VARCHAR(20)
);
drop table etl_execution_log;
CREATE TABLE etl_execution_log
(  execution_id CHAR(36),
    log_id INT AUTO_INCREMENT PRIMARY KEY,

    layer VARCHAR(20),

    table_name VARCHAR(100),

    start_time DATETIME(6),

    end_time DATETIME(6),

    duration_seconds DECIMAL(10,3),

    rows_loaded INT,

    status VARCHAR(20),

    message VARCHAR(500)
);

-- =====================================================
-- Verify Bronze Tables
-- =====================================================

