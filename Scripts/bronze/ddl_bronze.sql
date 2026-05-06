use DataWarehouse

/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

--CRM CUST INFO Table
IF OBJECT_ID ('bronze.crm_cust_info', 'U') IS NOT NULL
	DROP TABLE bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info(
cst_id integer,
cst_key NVARCHAR(50),
cst_firstname NVARCHAR(60),
cst_lastname NVARCHAR(60),
cst_marital_status NVARCHAR(50),
cst_gender NVARCHAR(50),
cst_create_date DATE
);

--CRM PRD_INFO Table
IF OBJECT_ID ('bronze.crm_prd_info', 'U') IS NOT NULL
	DROP TABLE bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info(
prd_id integer,
prd_key VARCHAR(60),
prd_nm VARCHAR(60),
prd_cost INTEGER,
prd_line VARCHAR(40),
prd_start_dt DATE,
prd_end_dt DATE
);

--CRM SALES_DETAILS Table
IF OBJECT_ID ('bronze.crm_sales_details', 'U') IS NOT NULL
	DROP TABLE bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details(
sls_ord_num INTEGER,
sls_prd_key VARCHAR(50),
sls_cust_id INTEGER,
sls_order_dt DATE,
sls_ship_dt DATE,
sls_due_dt DATE,
sls_sales INTEGER,
sls_quantity INTEGER,
sls_price INTEGER
);


--ERP Tables 

--ERP CUST_AZ12 Table
IF OBJECT_ID ('bronze.erp_CUST_AZ12', 'U') IS NOT NULL
	DROP TABLE bronze.erp_CUST_AZ12;
CREATE TABLE bronze.erp_CUST_AZ12(
CID VARCHAR(50),
BDATE DATE,
GEN VARCHAR(50)
);

--ERP LOC_A101 Table
IF OBJECT_ID ('bronze.LOC_A101', 'U') IS NOT NULL
	DROP TABLE bronze.LOC_A101;
CREATE TABLE bronze.LOC_A101(
CID VARCHAR(50),
CNTRY VARCHAR(60)
);

--ERP PX_CAT_G1V2
IF OBJECT_ID ('bronze.PX_CAT_G1V2', 'U') IS NOT NULL
	DROP TABLE bronze.PX_CAT_G1V2;
CREATE TABLE bronze.PX_CAT_G1V2(
ID VARCHAR(50),
CAT VARCHAR(60),
SUBCAT VARCHAR(60),
MAINTENANCE VARCHAR(50)
);
