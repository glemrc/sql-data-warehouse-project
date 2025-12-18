# 📘 Data Catalog – Gold Layer

## Descripción General

La capa **Gold** representa el nivel analítico del Data Warehouse.  
Está diseñada bajo un **modelo dimensional (Star Schema)** y contiene datos consolidados, limpios y listos para consumo por herramientas de BI, analítica y reporting.

Las tablas de esta capa se dividen en:
- **Dimensiones**: describen entidades del negocio.
- **Hechos**: registran eventos transaccionales y métricas.

---

## 🟨 Dimensiones

---

### 📊 gold.dim_customers

**Tipo de tabla:** Dimensión  
**Fuente:** CRM + ERP  

**Descripción:**  
Contiene la información maestra de los clientes, consolidando datos demográficos y geográficos provenientes de múltiples sistemas.

**Clave primaria:**  
- `customer_key` (clave sustituta)

**Grano:**  
- Una fila por cliente único.

#### Columnas

| Columna | Tipo lógico | Descripción |
|------|------------|------------|
| customer_key | Surrogate Key | Identificador interno único del cliente |
| customer_id | Business Key | Identificador natural del cliente en el CRM |
| customer_number | Business Key | Código externo del cliente |
| first_name | Atributo | Nombre del cliente |
| last_name | Atributo | Apellido del cliente |
| marital_status | Atributo | Estado civil del cliente |
| gender | Atributo | Género del cliente (CRM es la fuente maestra) |
| birthdate | Fecha | Fecha de nacimiento |
| country | Atributo | País de residencia |
| created_date | Fecha | Fecha de creación del cliente |

**Reglas de calidad:**
- `customer_key` no nulo ni duplicado.
- `gender` estandarizado (`Male`, `Female`, `n/a`).
- `birthdate` dentro de rangos válidos.

---

### 📊 gold.dim_product

**Tipo de tabla:** Dimensión  
**Fuente:** CRM + ERP  

**Descripción:**  
Almacena la información descriptiva de los productos, incluyendo su categorización y atributos comerciales.

**Clave primaria:**  
- `product_key` (clave sustituta)

**Grano:**  
- Una fila por producto único.

#### Columnas

| Columna | Tipo lógico | Descripción |
|------|------------|------------|
| product_key | Surrogate Key | Identificador interno único del producto |
| product_code | Business Key | Código del producto |
| product_name | Atributo | Nombre del producto |
| category_id | Atributo | Identificador de la categoría |
| category_name | Atributo | Nombre de la categoría |
| subcategory_name | Atributo | Nombre de la subcategoría |
| maintenance_type | Atributo | Tipo de mantenimiento |
| product_cost | Métrica | Costo del producto |
| product_line | Atributo | Línea de producto |
| product_start_date | Fecha | Fecha de inicio de vigencia |

**Reglas de calidad:**
- `product_key` no nulo ni duplicado.
- `product_cost` mayor o igual a cero.
- Fechas de vigencia consistentes.

---

## 🟦 Hechos

---

### 📈 gold.fact_sales

**Tipo de tabla:** Fact (Transactional)  
**Fuente:** CRM  

**Descripción:**  
Registra las transacciones de ventas, representando cada producto vendido dentro de una orden.

**Grano:**  
- Una fila por **producto vendido en una orden**.

**Claves foráneas:**
- `customer_key` → `dim_customers`
- `product_key` → `dim_product`

#### Columnas

| Columna | Tipo lógico | Descripción |
|------|------------|------------|
| order_number | Business Key | Número de la orden de venta |
| customer_key | FK | Clave sustituta del cliente |
| product_key | FK | Clave sustituta del producto |
| order_date | Fecha | Fecha de la orden |
| ship_date | Fecha | Fecha de envío |
| due_date | Fecha | Fecha de vencimiento |
| quantity_sold | Métrica | Cantidad vendida |
| unit_price | Métrica | Precio unitario |
| sales_amount | Métrica | Monto total de la venta |

**Reglas de calidad:**
- `sales_amount = quantity_sold × unit_price`
- No se permiten métricas negativas.
- Todas las claves foráneas deben existir en sus dimensiones.

---

## 🔗 Relaciones del Modelo

dim_customers (1) ────< fact_sales >──── (1) dim_product


