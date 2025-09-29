-- Ejercicio 1
-- Considere el siguiente DERExt (esq_articulos):
--
-- a)  Defina las siguientes vistas mediante sentencias SQL:
-- a.1) ENVIOS500 con los envíos de 500 o más unidades (a partir de ENVIO)
-- a.2) ENVIOS500M con los envíos de entre 500 y 1000 unidades (a partir de ENVIOS500)
-- a.3) RUBROS_PROV con los diferentes rubros que poseen los proveedores ubicados en Tandil
-- a.4) ENVIOS_PROV con los diferentes id y nombre de proveedor y la cantidad total de unidades enviadas
-- b) Determine si las vistas anteriores son automáticamente actualizables según el estándar SQL o no (en este caso indicar la/s causa/s).
-- c) Compruebe si resultan automáticamente actualizables para PostgreSQL, proporcionando sentencias de actualización sobre las vistas en cada caso.

-- a.1)
CREATE VIEW ENVIOS500 AS
    SELECT *
    FROM envio
    WHERE cantidad > 500;
-- Actualizable

-- a.2)
CREATE VIEW ENVIOS500M AS
    SELECT *
    FROM ENVIOS500
    WHERE cantidad BETWEEN 500 AND 1000;
-- Actualizable

-- a.3)
CREATE VIEW RUBROS_PROV AS
    SELECT DISTINCT rubro
    FROM proveedor
    WHERE ciudad = 'Tandil';
-- No Actualizable por el DISTINCT

-- a.4)
CREATE VIEW ENVIOS_PROV AS
    SELECT id_proveedor, nombre, count(*)
    FROM proveedor p JOIN envio e USING (id_proveedor)
    GROUP BY id_proveedor;
-- No actualizable. Porque se incluye una funcion de agregacion -> count(*). Y ademas que no aparecen en la vista todas las columnas de clave primaria (falta id_articulo).
-- Sumando las restricciones de postgres, que tiene que tener una sola entrada en el FROM y no puede tener GROUP BY.