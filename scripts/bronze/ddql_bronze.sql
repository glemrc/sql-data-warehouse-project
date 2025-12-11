/*
-----------------------------------------------
DDL SCRIPT: Creación de las tablas de 'Bronze'

Crea las tables de Bronze y si es que existen 
las 'Dropea'.
-----------------------------------------------
*/
EXEC bronze.load_bronze

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @star_time DATETIME, @end_time DATETIME, @batch_star_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_star_time = GETDATE();
		PRINT '======================================';
		PRINT 'Cargando Bronze Layer';
		PRINT '======================================';
	
		PRINT '--------------------------------------';
		PRINT 'Cargando CRM Tables'
		PRINT '--------------------------------------';
		
		SET @star_time = GETDATE();
		PRINT '>> Truncando TABLE bronze.crm_cust_info;'
		TRUNCATE TABLE bronze.crm_cust_info;

		PRINT '>> Insertando Data a bronze.crm_cust_info;'
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\acer\Desktop\curso sql\Data Warehouse\sql-data-warehouse-project-main\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);
		SET @end_time = GETDATE();
		PRINT '>>Duración de la Carga: ' + CAST(DATEDIFF(second, @star_time, @end_time) AS NVARCHAR) + ' segundos';
		PRINT '>>-------------------------';

		TRUNCATE TABLE bronze.crm_prd_info;
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\acer\Desktop\curso sql\Data Warehouse\sql-data-warehouse-project-main\datasets\source_crm\prd_info.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT '>>Duración de la Carga: ' + CAST(DATEDIFF(second, @star_time, @end_time) AS NVARCHAR) + ' segundos';
		PRINT '>>-------------------------';

		TRUNCATE TABLE bronze.crm_sales_details;
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\acer\Desktop\curso sql\Data Warehouse\sql-data-warehouse-project-main\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		)

		SET @end_time = GETDATE();
		PRINT '>>Duración de la Carga: ' + CAST(DATEDIFF(second, @star_time, @end_time) AS NVARCHAR) + ' segundos';
		PRINT '>>-------------------------';


		PRINT '--------------------------------------';
		PRINT 'Cargando ERP Tables'
		PRINT '--------------------------------------';
		TRUNCATE TABLE bronze.erp_loc_a101;
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\acer\Desktop\curso sql\Data Warehouse\sql-data-warehouse-project-main\datasets\source_erp\LOC_A101.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		)

		SET @end_time = GETDATE();
		PRINT '>>Duración de la Carga: ' + CAST(DATEDIFF(second, @star_time, @end_time) AS NVARCHAR) + ' segundos';
		PRINT '>>-------------------------';

		TRUNCATE TABLE bronze.erp_cust_az12;
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\acer\Desktop\curso sql\Data Warehouse\sql-data-warehouse-project-main\datasets\source_erp\CUST_AZ12.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		)
		
		SET @end_time = GETDATE();
		PRINT '>>Duración de la Carga: ' + CAST(DATEDIFF(second, @star_time, @end_time) AS NVARCHAR) + ' segundos';
		PRINT '>>-------------------------';

		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\acer\Desktop\curso sql\Data Warehouse\sql-data-warehouse-project-main\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @end_time = GETDATE();
		SET @batch_end_time = GETDATE();
		PRINT '>>Duración de la Carga: ' + CAST(DATEDIFF(second, @star_time, @end_time) AS NVARCHAR) + ' segundos';
		PRINT '--------------------------------------'
		PRINT '>>Duración de la Carga TOTAL: '+CAST(DATEDIFF(second, @batch_star_time, @batch_end_time) AS NVARCHAR) + ' segundos';
		END TRY
		BEGIN CATCH
			PRINT 'Un error ocurrio durante el cargado';
			PRINT 'Mensaje de error' + ERROR_MESSAGE();
		END CATCH
END
