/*
===============================================================================
Controles de Calidad – Capa Gold
===============================================================================
Propósito del script:
Este script realiza validaciones de calidad para asegurar la integridad,
consistencia y confiabilidad de los datos en la capa GOLD. Las verificaciones
incluyen:

- Unicidad de las claves sustitutas (surrogate keys) en las tablas dimensión.
- Integridad referencial entre la tabla de hechos y las dimensiones.
- Validación de las relaciones del modelo estrella para análisis analítico.
===============================================================================
*/

-- ====================================================================
-- Validación: gold.dim_customers
-- ====================================================================
-- Verificar unicidad de la clave de cliente
-- Expectativa: No debe retornar registros
SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;


-- ====================================================================
-- Validación: gold.dim_product
-- ====================================================================
-- Verificar unicidad de la clave de producto
-- Expectativa: No debe retornar registros
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_product
GROUP BY product_key
HAVING COUNT(*) > 1;


-- ====================================================================
-- Validación: gold.fact_sales
-- ====================================================================
-- Verificar integridad referencial entre hechos y dimensiones
-- Expectativa: No debe retornar registros
SELECT 
    *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_product p
    ON p.product_key = f.product_key
WHERE p.product_key IS NULL 
   OR c.customer_key IS NULL;
