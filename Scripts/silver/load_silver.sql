/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/

USE DataWarehouse

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
BEGIN TRY
	SET @Batch_start_time = GETDATE ();
	PRINT '================================================';
	PRINT 'Loading Silver Layer';
	PRINT '================================================';

	PRINT '------------------------------------------------';
	PRINT 'Loading CRM Tables';
	PRINT '------------------------------------------------';

	------------silver.crm_cust_info------------
	SET @start_time = GETDATE ();    
	PRINT '>> Truncating Table: silver.crm_cust_info';
	TRUNCATE TABLE silver.crm_cust_info
	PRINT '>> Inserting Data Into: silver.crm_cust_info';
	INSERT INTO silver.crm_cust_info(
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gender,
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
			END AS cst_marital_status, -- Normalize marital status values to readable format
		CASE 
			WHEN UPPER(TRIM(cst_gender)) = 'F' THEN 'Female'
			WHEN UPPER(TRIM(cst_gender)) = 'M' THEN 'Male'
			ELSE 'n/a'
			END AS cst_gndr, -- Normalize gender values to readable format
	cst_create_date
	FROM (
		SELECT
			*,
			ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
			FROM bronze.crm_cust_info
			WHERE cst_id IS NOT NULL
		) t
		WHERE flag_last = 1; -- Select the most recent record per customer

		SET @end_time = GETDATE ();  
		PRINT'>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'
		PRINT '------------------------------------------------------------';


	------------silver.crm_prd_info------------
	SET @start_time = GETDATE (); 
	PRINT '>> Truncating Table: silver.crm_prd_info';
	TRUNCATE TABLE silver.crm_prd_info
	PRINT '>> Inserting Data Into: silver.crm_prd_info';
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
	TRIM(REPLACE (SUBSTRING (prd_key,1, 5), '-', '_')) AS cat_id,
	TRIM(SUBSTRING(prd_key, 7, LEN(prd_key))) AS prd_key,
	TRIM(prd_nm) AS prd_nm,
	ISNULL (prd_cost, 0) AS prd_cost,
	CASE
		WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
		WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
		WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
		WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
		ELSE 'N/A'
	END AS prd_line,
	CAST (prd_start_dt AS DATE) AS prd_start_dt,
	(DATEADD(DAY, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt))) AS prd_end_dt
	FROM bronze.crm_prd_info
	SET @end_time = GETDATE ();  
		PRINT'>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'
		PRINT '------------------------------------------------------------';


	------------silver.crm_sales_details------------
	SET @start_time = GETDATE();
	PRINT '>> Truncating Table: silver.crm_sales_details';
	TRUNCATE TABLE silver.crm_sales_details
	PRINT '>> Inserting Data Into: silver.crm_sales_details';
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
	TRIM(sls_ord_num) AS sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE WHEN sls_order_dt = 0 or LEN(sls_order_dt) != 8 
	THEN NULL
	ELSE CAST (CAST (sls_order_dt AS VARCHAR) AS DATE)
	END as sls_order_dt,
	CASE WHEN sls_ship_dt = 0 or LEN(sls_ship_dt) != 8 
	THEN NULL
	ELSE CAST (CAST (sls_ship_dt AS VARCHAR) AS DATE)
	END as sls_ship_dt,
	CASE WHEN sls_due_dt = 0 or LEN(sls_due_dt) != 8 
	THEN NULL
	ELSE CAST (CAST (sls_due_dt AS VARCHAR) AS DATE)
	END as sls_due_dt,
	CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)    -- ABS converts - to +
		THEN sls_quantity * ABS(sls_price)
		ELSE sls_sales
	END AS sls_sales,
	sls_quantity,
	CASE WHEN sls_price IS NULL OR sls_price <=0 
		THEN sls_sales/NULLIF(sls_quantity, 0)
		ELSE sls_price 
	END AS sls_price
	FROM
	bronze.crm_sales_details
	SET @end_time = GETDATE();
	PRINT'>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'
	PRINT '------------------------------------------------------------';

		PRINT '------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '------------------------------------------------';
	
	------------silver.erp_CUST_AZ12------------
	SET @start_time = GETDATE();
	TRUNCATE TABLE silver.erp_CUST_AZ12
	INSERT INTO silver.erp_CUST_AZ12(
	CID,
	BDATE,
	GEN
	)
	SELECT
	CASE WHEN
		CID LIKE 'NAS%' THEN SUBSTRING(CID, 4, LEN(CID))            -- AS we need to join this table from crm_cust_info (cst_key)
		ELSE CID
	END CID,
	CASE WHEN BDATE > GETDATE() THEN NULL
		ELSE BDATE
	END AS BDATE,
	CASE WHEN UPPER(TRIM(GEN)) IN ('F', 'FEMALE') THEN 'Female'
		 WHEN UPPER(TRIM(GEN)) IN ('M', 'MALE') THEN 'Male'
		ELSE 'N/A'
	END AS GEN 
	FROM bronze.erp_CUST_AZ12

	------------silver.erp_CUST_AZ12------------

	TRUNCATE TABLE silver.LOC_A101
	INSERT INTO silver.LOC_A101(
	CID,
	CNTRY
	)
	SELECT 
	REPLACE(CID, '-', '') AS CID,
	CASE WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
		 WHEN TRIM(CNTRY) IN ('USA', 'US') THEN 'United States'
		 WHEN TRIM(CNTRY) = '' OR CNTRY IS NULL THEN 'N/A'
		 ELSE TRIM(CNTRY)
	END AS CNTRY
	FROM bronze.LOC_A101 
	SET @end_time = GETDATE ();  
	PRINT'>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'
	PRINT '------------------------------------------------------------';

	------------silver.PX_CAT_G1V2------------
	SET @start_time = GETDATE();
	TRUNCATE TABLE silver.PX_CAT_G1V2
	INSERT INTO silver.PX_CAT_G1V2(
	ID,
	CAT,
	SUBCAT,
	MAINTENANCE
	)
	SELECT
	ID,
	CAT,
	SUBCAT,
	MAINTENANCE
	FROM bronze.PX_CAT_G1V2
	SET @end_time = GETDATE ();  
	PRINT'>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'
	PRINT '------------------------------------------------------------';

	SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading Silver Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='
	END TRY
	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH
END


EXEC silver.load_silver
