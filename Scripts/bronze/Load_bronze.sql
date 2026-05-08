-- WE ARE DOING A FULL LOAD(BATCH INSERT) IN THIS:
-- TRY CATCH SQL will run the TRY block first if it fails then it will run the catch block

use DataWarehouse

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @Batch_start_time DATETIME, @Batch_end_time DATETIME;      -- Trace ETL Duration
BEGIN TRY
	SET @Batch_start_time = GETDATE ();
		PRINT '============================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '============================================================';


		PRINT '------------------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '------------------------------------------------------------';
		--1) CRM bronze.crm_cust_info
		SET @start_time = GETDATE ();                      --Get the start time
		PRINT '>> Truncating Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;

		PRINT '>> Inserting Value Into: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\ASUS\Desktop\data Warehouse project\sql-data-warehouse-project-main\datasets\source_crm\cust_info.csv'
		WITH(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
		);

		SET @end_time = GETDATE ();  
		PRINT'>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'
		PRINT '------------------------------------------------------------';

		--2) CRM bronze.crm_prd_info
		SET @start_time = GETDATE ();
		PRINT '>> Truncating Table: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;

		PRINT '>> Inserting Value Into: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\ASUS\Desktop\data Warehouse project\sql-data-warehouse-project-main\datasets\source_crm\prd_info.csv'
		WITH(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
		);
		SET @end_time = GETDATE ();  
		PRINT'>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'
		PRINT '------------------------------------------------------------';


		--3) CRM bronze.crm_sales_details
		SET @start_time = GETDATE ();
		PRINT '>> Truncating Table: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;

		PRINT '>> Inserting Value Into: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\ASUS\Desktop\data Warehouse project\sql-data-warehouse-project-main\datasets\source_crm\sales_details.csv'
		WITH(
		FORMAT = 'csv',
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
		);
		SET @end_time = GETDATE ();  
		PRINT'>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'
		PRINT '------------------------------------------------------------';
		---------------------------------------------------------------------------------------------------------

		PRINT '------------------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '------------------------------------------------------------';

		--1) ERP bronze.erp_CUST_AZ12
		SET @start_time = GETDATE ();
		PRINT '>> Truncating Table: bronze.erp_CUST_AZ12';
		TRUNCATE TABLE bronze.erp_CUST_AZ12;

		PRINT '>> Inserting Value Into: bronze.erp_CUST_AZ12';
		BULK INSERT bronze.erp_CUST_AZ12
		FROM 'C:\Users\ASUS\Desktop\data Warehouse project\sql-data-warehouse-project-main\datasets\source_erp\CUST_AZ12.csv'
		WITH(
		FIRSTROW =2,
		FIELDTERMINATOR = ','
		);
		SET @end_time = GETDATE ();  
		PRINT'>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'
		PRINT '------------------------------------------------------------';


		--2) ERP bronze.LOC_A101
		SET @start_time = GETDATE ();
		PRINT '>> Truncating Table: ERP bronze.LOC_A101';
		TRUNCATE TABLE bronze.LOC_A101

		PRINT '>> Inserting Value Into: bronze.LOC_A101';
		BULK INSERT bronze.LOC_A101
		FROM 'C:\Users\ASUS\Desktop\data Warehouse project\sql-data-warehouse-project-main\datasets\source_erp\LOC_A101.csv'
		WITH(
		FIRSTROW =2,
		FIELDTERMINATOR = ','
		);
		SET @end_time = GETDATE ();  
		PRINT'>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'
		PRINT '------------------------------------------------------------';


		--3) ERP bronze.PX_CAT_G1V2
		SET @start_time = GETDATE ();
		PRINT '>> Truncating Table: bronze.PX_CAT_G1V2';
		TRUNCATE TABLE bronze.PX_CAT_G1V2

		PRINT '>> Inserting Value Into: bronze.PX_CAT_G1V2';
		BULK INSERT bronze.PX_CAT_G1V2
		FROM 'C:\Users\ASUS\Desktop\data Warehouse project\sql-data-warehouse-project-main\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH(
		FIRSTROW =2,
		FIELDTERMINATOR = ','
		);
		SET @end_time = GETDATE ();  
		PRINT'>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'
		PRINT'----------------------------------------------------------------------------------------------------'

		PRINT'>> Bronze Layer Loading Completed <<'
		SET @Batch_end_time = GETDATE ();  
		PRINT'>> Load Duration:' + CAST(DATEDIFF(second, @Batch_start_time, @Batch_end_time) AS NVARCHAR) + 'seconds'
		PRINT'----------------------------------------------------------------------------------------------------'

END TRY
BEGIN CATCH
PRINT'========================================================='
PRINT'ERROR OCCURED DURING LOADING BRONZE LAYER'
PRINT'Error Message' + error_message ();    --calling the error message function
PRINT'Error Message' + cast(error_number () as NVARCHAR);  --We used CAST to conver the number into VARCHAR              
PRINT'Error Message' + cast(error_state () as NVARCHAR);
PRINT'========================================================='
END CATCH
END 



EXEC bronze.load_bronze;    -- To execute the complete above query
