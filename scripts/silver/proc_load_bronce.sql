/*
-----------------------------------------------
Stored Procedure: Load Silver Layer (Bronze → Silver)

Propósito del Script:
Este procedimiento almacenado ejecuta el proceso ETL (Extracción, Transformación y Carga)
para poblar las tablas del esquema "silver" a partir de los datos contenidos en el esquema
"bronze" dentro del Data Warehouse.

Acciones Realizadas:
- Trunca las tablas del esquema Silver para asegurar cargas limpias.
- Aplica reglas de transformación y normalización de datos.
- Depura registros inconsistentes o inválidos.
- Inserta los datos transformados desde Bronze hacia Silver.
- Calcula y muestra el tiempo de ejecución por tabla y del proceso completo.

Ejemplo de Uso:
EXEC silver.load_silver;
-----------------------------------------------
*/

CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
    DECLARE 
        @start_time DATETIME,
        @end_time DATETIME,
        @batch_start_time DATETIME,
        @batch_end_time DATETIME;

    BEGIN TRY
        SET @batch_start_time = GETDATE();

        PRINT '===================================================';
        PRINT 'INICIO CARGA SILVER LAYER';
        PRINT '===================================================';

        /* ===================================================
           CRM - CUSTOMER INFO
        =================================================== */
        SET @start_time = GETDATE();

        PRINT 'Truncando tabla: silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;

        PRINT 'Insertando datos en: silver.crm_cust_info';
        INSERT INTO silver.crm_cust_info (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_created_date
        )
        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname),
            TRIM(cst_lastname),
            CASE 
                WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cst_material_status)) = 'M' THEN 'Married'
                ELSE 'n/a'
            END,
            CASE 
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                ELSE 'n/a'
            END,
            cst_creadte_date
        FROM (
            SELECT *,
                   ROW_NUMBER() OVER (
                       PARTITION BY cst_id 
                       ORDER BY cst_creadte_date DESC
                   ) AS flag_last
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) t
        WHERE flag_last = 1;

        SET @end_time = GETDATE();
        PRINT '>> Duración crm_cust_info: ' 
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) 
              + ' segundos';

        /* ===================================================
           CRM - PRODUCT INFO
        =================================================== */
        SET @start_time = GETDATE();

        PRINT 'Truncando tabla: silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;

        PRINT 'Insertando datos en: silver.crm_prd_info';
        INSERT INTO silver.crm_prd_info (
            pr_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT
            pr_id,
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
            SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
            prd_nm,
            ISNULL(prd_cost, 0),
            CASE UPPER(TRIM(prd_line))
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'Other Sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'n/a'
            END,
            CAST(prd_start_dt AS DATE),
            CAST(
                LEAD(prd_start_dt) OVER (
                    PARTITION BY prd_key 
                    ORDER BY prd_start_dt
                ) - 1 AS DATE
            )
        FROM bronze.crm_prd_info;

        SET @end_time = GETDATE();
        PRINT '>> Duración crm_prd_info: ' 
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) 
              + ' segundos';

        /* ===================================================
           CRM - SALES DETAILS
        =================================================== */
        SET @start_time = GETDATE();

        PRINT 'Truncando tabla: silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;

        PRINT 'Insertando datos en: silver.crm_sales_details';
        INSERT INTO silver.crm_sales_details (
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
            sls_ord_key,
            sls_cust_id,
            CASE 
                WHEN sls_order_dt = 0 OR LEN(sls_order_dt) <> 8 THEN NULL
                ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
            END,
            CASE 
                WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) <> 8 THEN NULL
                ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
            END,
            CASE 
                WHEN sls_due_dt = 0 OR LEN(sls_due_dt) <> 8 THEN NULL
                ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
            END,
            CASE 
                WHEN sls_sales IS NULL 
                     OR sls_sales <= 0
                     OR sls_sales <> sls_quantity * ABS(sls_price)
                THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales
            END,
            sls_quantity,
            CASE 
                WHEN sls_price IS NULL OR sls_price = 0
                    THEN sls_sales / NULLIF(sls_quantity, 0)
                WHEN sls_price < 0
                    THEN ABS(sls_price)
                ELSE sls_price
            END
        FROM bronze.crm_sales_details;

        SET @end_time = GETDATE();
        PRINT '>> Duración crm_sales_details: ' 
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) 
              + ' segundos';

        /* ===================================================
           ERP - CUSTOMER
        =================================================== */
        SET @start_time = GETDATE();

        PRINT 'Truncando tabla: silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12;

        INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
        SELECT
            CASE 
                WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
                ELSE cid
            END,
            CASE 
                WHEN bdate > GETDATE() THEN NULL
                ELSE bdate
            END,
            CASE 
                WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
                WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
                ELSE 'n/a'
            END
        FROM bronze.erp_cust_az12;

        SET @end_time = GETDATE();
        PRINT '>> Duración erp_cust_az12: ' 
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) 
              + ' segundos';

        /* ===================================================
           ERP - LOCATION
        =================================================== */
        SET @start_time = GETDATE();

        PRINT 'Truncando tabla: silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_loc_a101;

        INSERT INTO silver.erp_loc_a101 (cid, cntry)
        SELECT
            REPLACE(cid, '-', ''),
            CASE 
                WHEN cntry = 'DE' THEN 'Germany'
                WHEN cntry LIKE 'US%' THEN 'United States'
                WHEN cntry IS NULL OR cntry = '' THEN 'n/a'
                ELSE cntry
            END
        FROM bronze.erp_loc_a101;

        SET @end_time = GETDATE();
        PRINT '>> Duración erp_loc_a101: ' 
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) 
              + ' segundos';

        /* ===================================================
           ERP - PRODUCT CATEGORY
        =================================================== */
        SET @start_time = GETDATE();

        PRINT 'Truncando tabla: silver.erp_px_cat_g1v2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
        SELECT id, cat, subcat, maintenance
        FROM bronze.erp_px_cat_g1v2;

        SET @end_time = GETDATE();
        PRINT '>> Duración erp_px_cat_g1v2: ' 
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) 
              + ' segundos';

        /* ===================================================
           FIN DEL BATCH
        =================================================== */
        SET @batch_end_time = GETDATE();

        PRINT '===================================================';
        PRINT 'FIN CARGA SILVER LAYER';
        PRINT 'Duración total: ' 
              + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) 
              + ' segundos';
        PRINT '===================================================';

    END TRY
    BEGIN CATCH
        PRINT 'ERROR EN CARGA SILVER LAYER';
        PRINT ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO
