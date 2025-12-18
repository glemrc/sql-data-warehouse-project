/*
====================================================================
DDL: Gold Layer (Dimensiones y Hechos)
====================================================================

Propósito:
Este script crea las vistas del esquema GOLD, las cuales representan
la capa analítica del Data Warehouse. Estas vistas están optimizadas
para consumo por herramientas de BI y análisis.

Acciones realizadas:
- Elimina las vistas si ya existen.
- Crea las dimensiones:
  - gold.dim_product
  - gold.dim_customers
- Crea la tabla de hechos:
  - gold.fact_sales

Fuente de datos:
- Esquema SILVER
====================================================================
*/

-- ================================================================
-- Dimensión: Productos
-- ================================================================
DROP VIEW IF EXISTS gold.dim_product;
GO

CREATE VIEW gold.dim_product AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
    pn.pr_id           AS product_id,
    pn.prd_key         AS product_code,
    pn.prd_nm          AS product_name,
    pn.cat_id          AS category_id,
    pcg.cat            AS category_name,
    pcg.subcat         AS subcategory_name,
    pcg.maintenance    AS maintenance_type,
    pn.prd_cost        AS product_cost,
    pn.prd_line        AS product_line,
    pn.prd_start_dt    AS product_start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pcg
    ON pn.cat_id = pcg.id
WHERE pn.prd_end_dt IS NULL; -- Se filtra solo productos vigentes


-- ================================================================
-- Dimensión: Clientes
-- ================================================================
DROP VIEW IF EXISTS gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
    ci.cst_id              AS customer_id,
    ci.cst_key             AS customer_number,
    ci.cst_firstname       AS first_name,
    ci.cst_lastname        AS last_name,
    ci.cst_marital_status  AS marital_status,
    CASE
        WHEN ci.cst_gndr != 'n/a' 
            THEN ci.cst_gndr     -- CRM es la fuente maestra de género
        ELSE COALESCE(ca.gen, 'n/a')
    END AS gender,
    ca.bdate               AS birthdate,
    la.cntry               AS country,
    ci.cst_created_date    AS created_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid;


-- ================================================================
-- Tabla de Hechos: Ventas
-- ================================================================
DROP VIEW IF EXISTS gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT 
    sd.sls_ord_num   AS order_number,
    sd.sls_prd_key   AS product_code,
    pr.product_key   AS product_key,
    cm.customer_key  AS customer_key,
    sd.sls_cust_id   AS customer_id,
    sd.sls_order_dt  AS order_date,
    sd.sls_ship_dt   AS ship_date,
    sd.sls_due_dt    AS due_date,
    sd.sls_sales     AS sales_amount,
    sd.sls_quantity  AS quantity_sold,
    sd.sls_price     AS unit_price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_product pr
    ON sd.sls_prd_key = pr.product_code
LEFT JOIN gold.dim_customers cm
    ON sd.sls_cust_id = cm.customer_id;
