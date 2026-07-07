/*=========================================================
 Project     : SQL Data Warehouse Project (MySQL)
 Layer       : silver
 Purpose     : Create silver Layer Tables
 Author      : Maram VijayReddy
=========================================================*/

-- =====================================================
-- Drop Existing silver Tables
-- =====================================================
use datawarehouse;
DROP TABLE IF EXISTS silver_crm_cust_info;

DROP TABLE IF EXISTS silver_erp_loc_a101;
DROP TABLE IF EXISTS silver_erp_px_cat_g1v2;

-- =====================================================
-- Create CRM Customer Information Table
-- =====================================================
drop table silver_crm_cust_info;
CREATE TABLE silver_crm_cust_info
(
    cst_id              VARCHAR(20),
    cst_key             VARCHAR(50),
    cst_firstname       VARCHAR(50),
    cst_lastname        VARCHAR(50),
    cst_marital_status  VARCHAR(20),
    cst_gndr            VARCHAR(20),
    cst_create_date     VARCHAR(20),
	dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- Create CRM Product Information Table
-- =====================================================
SELECT * FROM datawarehouse.bronze_crm_prd_info;
DROP TABLE IF EXISTS silver_crm_prd_info;
CREATE TABLE silver_crm_prd_info
(
    prd_id         int,
    cat_id 		varchar(20),
    prd_key         VARCHAR(50),
    prd_nm          VARCHAR(100),
    prd_cost        int,
    prd_line        VARCHAR(50),
    prd_start_dt    date,
    prd_end_dt      date,
		dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- Create CRM Sales Details Table
-- =====================================================
DROP TABLE IF EXISTS silver_crm_sales_details;

CREATE TABLE silver_crm_sales_details
(
    sls_ord_num     VARCHAR(20),
    sls_prd_key     VARCHAR(20),
    sls_cust_id     VARCHAR(20),
    sls_order_dt    date,
    sls_ship_dt     date,
    sls_due_dt      date,
    sls_sales      DECIMAL(10,2),
	sls_quantity   INT,
	sls_price      DECIMAL(10,2),
    	dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- Create ERP Customer Information Table
-- =====================================================
drop table silver_erp_cust_az12;
CREATE TABLE silver_erp_cust_az12
(
    CID         VARCHAR(20),
    BDATE       date,
    GEN         VARCHAR(20),
    	dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- Create ERP Location Table
-- =====================================================

CREATE TABLE silver_erp_loc_a101
(
    CID         VARCHAR(20),
    CNTRY       VARCHAR(50),
    	dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);
-- =====================================================
-- Create ERP Product Category Table
-- =====================================================
drop table silver_erp_px_cat_g1v2;
CREATE TABLE silver_erp_px_cat_g1v2
(
    ID              VARCHAR(20),
    CAT             VARCHAR(50),
    SUBCAT          VARCHAR(50),
    MAINTENANCE     VARCHAR(20),
    	dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

