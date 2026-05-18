USE DataWarehouse 
-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================

IF OBJECT_ID('gold.dim_customer', 'V') IS NOT NULL
    DROP VIEW gold.dim_customer;
GO

CREATE VIEW gold.dim_customer AS
	SELECT
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
		CI.cst_id AS customer_id,
		CI.cst_key AS customer_no, 
		CI.cst_firstname AS first_name,
		CI.cst_lastname AS last_name,
		LA.CNTRY AS country,
		CI.cst_marital_status AS marital_status,
CASE WHEN CI.cst_gender != 'n/a' THEN CI.cst_gender   --CRM is the master data 
	ELSE COALESCE(CA.GEN, 'n/a')
END AS gender,
		CA.BDATE AS birthdate,
		CI.cst_create_date AS create_date
	FROM silver.crm_cust_info AS CI
	LEFT JOIN silver.erp_CUST_AZ12 CA
	ON CI.cst_key = CA.CID
	LEFT JOIN silver.LOC_A101 LA
	ON CI.cst_key = LA.CID

	GO
	

-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================

IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT 
ROW_NUMBER() OVER (ORDER BY PI.prd_start_dt, PI.prd_key) AS product_key,
PI.prd_id AS product_id,
PI.prd_key AS product_no,
PI.prd_nm AS product_name,
PI.cat_id AS catogery_id,
PC.CAT AS catogery,
PC.SUBCAT AS sub_catogery,
PC.MAINTENANCE AS maintenance,
PI.prd_cost AS product_cost,
PI.prd_line AS product_line,
PI.prd_start_dt AS product_start_date  -- We don't need end date as we do not want historical data
FROM silver.crm_prd_info AS PI
LEFT JOIN silver.PX_CAT_G1V2 AS PC
ON PI.cat_id = PC.ID
WHERE PI.prd_end_dt IS NULL    -- To filter out historical data
SELECT * FROM gold.dim_products

GO


-- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================

-- Use dimension table's surrogate key to connect with fact table

IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO


CREATE VIEW gold.fact_sales AS
SELECT
    sd.sls_ord_num  AS order_number,
    pr.product_key,
    cd.customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt  AS shipping_date,
    sd.sls_due_dt   AS due_date,
    sd.sls_sales    AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price    AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products AS pr
ON pr.product_no = sd.sls_prd_key
LEFT JOIN gold.dim_customer cd
ON sd.sls_cust_id = cd.customer_id

GO
