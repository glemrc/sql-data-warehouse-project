# 🚀 Modern Data Warehouse con Arquitectura Medallion (Bronze · Silver · Gold)

## 📌 Descripción del Proyecto

Este proyecto implementa un **Data Warehouse moderno de extremo a extremo**, aplicando la **arquitectura Medallion (Bronze, Silver y Gold)** para la integración, limpieza, transformación y modelado de datos provenientes de sistemas **CRM y ERP**.

El objetivo es demostrar buenas prácticas de **Data Engineering**, **modelado dimensional** y **control de calidad de datos**, construyendo una base sólida para análisis analítico y reporting.

Este repositorio forma parte de mi **portafolio profesional**, orientado a roles de **Data Engineer / Analytics Engineer**.

---

## 🧱 Arquitectura del Proyecto

El proyecto sigue el enfoque **Medallion Architecture**:

### 🥉 Bronze Layer
- Ingesta de datos crudos desde archivos CSV (CRM y ERP).
- Sin transformaciones complejas.
- Preserva el historial original de los datos.
- Scripts de creación y carga inicial.

### 🥈 Silver Layer
- Limpieza y estandarización de datos.
- Normalización de formatos (fechas, textos, códigos).
- Eliminación de duplicados.
- Aplicación de reglas de negocio.
- Validaciones de calidad por tabla.

### 🥇 Gold Layer
- Modelo dimensional (Star Schema).
- Dimensiones y tabla de hechos listas para análisis.
- Integridad referencial garantizada.
- Validaciones finales del modelo analítico.

---

## 📊 Modelo de Datos (Gold Layer)

### Dimensiones
- **`gold.dim_customers`**
  - Información consolidada de clientes (CRM + ERP).
  - Manejo de claves sustitutas (`customer_key`).

- **`gold.dim_product`**
  - Catálogo de productos con categorización y atributos de negocio.
  - Manejo de histórico mediante fechas de vigencia.

### Tabla de Hechos
- **`gold.fact_sales`**
  - Ventas transaccionales.
  - Conectada a dimensiones de clientes y productos.
  - Métricas listas para análisis (ventas, cantidad, precio).

---
## 📈 Dashboard Ejecutivo – Vista Directiva

### 🎯 Objetivo del Dashboard
Proveer una **vista ejecutiva de desempeño comercial**, enfocada en:

- Evolución temporal de ventas  
- Crecimiento interanual (YoY)  
- Distribución por categorías  
- Principales clientes  
- KPIs clave para la toma de decisiones  

El dashboard fue diseñado bajo principios de **minimalismo, claridad y storytelling**, priorizando **insights accionables** sobre el detalle operativo.

---

### 🖼️ Vista General
- 📌 **Periodo analizado:** Dic-2010 a Ene-2014  
- 📌 **Fuente:** Capa Gold del Data Warehouse  
- 📌 **Herramienta:** Power BI  

![Vista Directiva – Dashboard Ejecutivo](documentos/vista_directiva.pdf)


---

### 📌 Componentes del Dashboard

#### 🔹 KPIs Ejecutivos
- **Ventas Totales**
- **Cantidad Total Vendida**
- **Average Ticket**

Diseñados para responder rápidamente a la pregunta:
> **“¿Cómo estamos hoy?”**

---

#### 🔹 Evolución Temporal de Ventas
- Análisis mensual de ventas.
- Implementación de la técnica **Focus + Context**:
  - Año principal destacado.
  - Años anteriores atenuados.
- Permite identificar **tendencias**, **estacionalidad** y **puntos de inflexión**.

---

#### 🔹 Cantidad Vendida por Categoría
- Visualización de participación porcentual.
- Facilita identificar **categorías dominantes** y **oportunidades de crecimiento**.

---

#### 🔹 Top 5 Clientes
- Ranking dinámico de clientes por ventas.
- Permite identificar **concentración de ingresos** y **clientes clave**.

---

#### 🔹 YoY Growth %
- Comparación interanual de ventas.
- Indicadores visuales de crecimiento positivo o negativo.
- Se excluyen años incompletos para evitar **distorsiones analíticas**.

---

### 🧠 Decisiones Analíticas Clave
- Se ajustó la **tabla calendario** al rango real de datos para evitar ruido y comparaciones inválidas.
- Los cálculos de **YoY** devuelven `BLANK()` cuando el año previo no existe en el contexto.
- Se priorizó **legibilidad ejecutiva** sobre densidad de información.
- El dashboard consume exclusivamente la **Gold Layer**, respetando el principio de separación entre **ingeniería** y **analítica**.

---
## 📁 Estructura del Repositorio

```
datasets/
├── source_crm/
│   ├── cust_info.csv
│   ├── prd_info.csv
│   └── sales_details.csv
├── source_erp/
│   ├── CUST_AZ12.csv
│   ├── LOC_A101.csv
│   └── PX_CAT_G1V2.csv
documentos/
├── data_model.jpg
├── dataflow_diagram.jpg
├── integration_model.jpg
└── data_catalog.md
scripts/
├── bronze/
│   ├── ddl_bronze.sql
│   └── proc_load_bronze.sql
├── silver/
│   ├── ddl_silver.sql
│   ├── proc_load_silver.sql
│   └── quality_checks_silver.sql
├── gold/
│   ├── ddl_gold.sql
│   └── quality_checks_gold.sql
├── init_database.sql
LICENSE
README.md
```

## ✅ Controles de Calidad de Datos

Se implementan **quality checks** en Silver y Gold para asegurar:

- Unicidad de claves primarias y sustitutas.
- Integridad referencial entre hechos y dimensiones.
- Consistencia de métricas (ventas = cantidad × precio).
- Validación de fechas y rangos válidos.
- Estandarización de valores categóricos.

Los scripts de validación se encuentran en:
- `scripts/silver/quality_checks_silver.sql`
- `scripts/gold/quality_checks_gold.sql`

---

## 🛠️ Tecnologías Utilizadas

- **SQL Server**
- **T-SQL**
- **Modelado Dimensional**
- **Arquitectura Medallion**
- **Git & GitHub**

---

## ▶️ Ejecución del Proyecto

1. Ejecutar `init_database.sql`
2. Crear tablas Bronze (`ddl_bronze.sql`)
3. Cargar datos Bronze (`proc_load_bronze.sql`)
4. Crear tablas Silver (`ddl_silver.sql`)
5. Ejecutar carga Silver (`proc_load_silver.sql`)
6. Validar calidad Silver
7. Crear vistas Gold (`ddl_gold.sql`)
8. Ejecutar validaciones Gold

---

## 📄 Documentación Adicional

- 📘 **Data Catalog**: `data_catalog.md`
- 🧩 Diagramas de arquitectura y modelo en `/documentos`

---

## 👤 Autor

Proyecto desarrollado como parte de mi **portafolio profesional en Data Engineering**, demostrando diseño de Data Warehouse, SQL avanzado y buenas prácticas de calidad de datos.

---



