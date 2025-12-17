-- ====================================================================
-- Validación de la tabla 'silver.crm_cust_info'
-- ====================================================================

-- Verificar valores NULL o duplicados en la clave primaria
-- Resultado esperado: Sin registros
SELECT 
    cst_id,
    COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Verificar espacios en blanco no deseados
-- Resultado esperado: Sin registros
SELECT 
    cst_key 
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- Estandarización y consistencia de datos
SELECT DISTINCT 
    cst_marital_status 
FROM silver.crm_cust_info;

-- ====================================================================
-- Validación de la tabla 'silver.crm_prd_info'
-- ====================================================================

-- Verificar valores NULL o duplicados en la clave primaria
-- Resultado esperado: Sin registros
SELECT 
    pr_id,
    COUNT(*) 
FROM silver.crm_prd_info
GROUP BY pr_id
HAVING COUNT(*) > 1 OR pr_id IS NULL;

-- Verificar espacios en blanco no deseados
-- Resultado esperado: Sin registros
SELECT 
    prd_nm 
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Verificar valores NULL o negativos en el costo del producto
-- Resultado esperado: Sin registros
SELECT 
    prd_cost 
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Estandarización y consistencia de datos
SELECT DISTINCT 
    prd_line 
FROM silver.crm_prd_info;

-- Verificar orden inválido de fechas (Fecha fin < Fecha inicio)
-- Resultado esperado: Sin registros
SELECT 
    * 
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- ====================================================================
-- Validación de la tabla 'silver.crm_sales_details'
-- ====================================================================

-- Verificar fechas inválidas
-- Resultado esperado: Sin fechas inválidas
SELECT 
    NULLIF(sls_due_dt, 0) AS sls_due_dt 
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 
    OR LEN(sls_due_dt) != 8 
    OR sls_due_dt > 20500101 
    OR sls_due_dt < 19000101;

-- Verificar orden inválido de fechas (Fecha de orden > Fecha de envío o vencimiento)
-- Resultado esperado: Sin registros
SELECT 
    * 
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt;

-- Verificar consistencia de datos: Ventas = Cantidad * Precio
-- Resultado esperado: Sin registros
SELECT DISTINCT 
    sls_sales,
    sls_quantity,
    sls_price 
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

-- ====================================================================
-- Validación de la tabla 'silver.erp_cust_az12'
-- ====================================================================

-- Identificar fechas fuera de rango
-- Resultado esperado: Fechas de nacimiento entre 1924-01-01 y la fecha actual
SELECT DISTINCT 
    bdate 
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' 
   OR bdate > GETDATE();

-- Estandarización y consistencia de datos
SELECT DISTINCT 
    gen 
FROM silver.erp_cust_az12;

-- ====================================================================
-- Validación de la tabla 'silver.erp_loc_a101'
-- ====================================================================

-- Estandarización y consistencia de datos
SELECT DISTINCT 
    cntry 
FROM silver.erp_loc_a101
ORDER BY cntry;

-- ====================================================================
-- Validación de la tabla 'silver.erp_px_cat_g1v2'
-- ====================================================================

-- Verificar espacios en blanco no deseados
-- Resultado esperado: Sin registros
SELECT 
    * 
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
   OR subcat != TRIM(subcat) 
   OR maintenance != TRIM(maintenance);

-- Estandarización y consistencia de datos
SELECT DISTINCT 
    maintenance 
FROM silver.erp_px_cat_g1v2;
