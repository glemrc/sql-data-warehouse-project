USE master;
GO

--Eliminar si es que ya existe la DB--
IF EXISTS (SELECT 1 FROM  sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END;
GO

--Creando la base de datos--
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

--Creando los esquemas--
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
