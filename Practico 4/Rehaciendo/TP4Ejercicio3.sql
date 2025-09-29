-- Ejercicio 3
-- A partir del Ejercicio 1)
-- a) ¿Qué sucedería con las actualizaciones sobre las vistas definidas si se agrega WITH CHECK OPTION?
-- b) Determine el efecto de las siguientes operaciones sobre la vista Envios500, según tenga especificada opción de chequeo (WITH CHECK OPTION) o no.
--    Nota: considere que existen los proveedores P1 y P2 y los artículos A1 y A2
-- d.1) INSERT INTO ENVIOS500 VALUES (‘P1’, ‘A1’, 500);
-- d.2) INSERT INTO ENVIOS500 VALUES (‘P2’, ‘A2’, 300);
-- d.3) UPDATE ENVIOS500 SET cantidad=100 WHERE id_proveedor= ’P1’;
-- d.4) UPDATE ENVIOS500 SET cantidad=1000 WHERE id_proveedor= ’P2’;
-- d.5) INSERT INTO ENVIOS500 VALUES (‘P1’, ‘A3’, 700);


-- a.1)
CREATE OR REPLACE VIEW ENVIOS500 AS
    SELECT *
    FROM envio
    WHERE cantidad >= 500
WITH CHECK OPTION;
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

INSERT INTO proveedor (id_proveedor, nombre, rubro, ciudad) VALUES ('P1', 'Proveedor1', 'Rubro1', 'Tandil');
INSERT INTO proveedor (id_proveedor, nombre, rubro, ciudad) VALUES ('P2', 'Proveedor2', 'Rubro2', 'Tandil');
INSERT INTO articulo (id_articulo, descripcion, precio, peso, ciudad) VALUES ('A1', 'Articulo1', 200, null, 'Tandil');
INSERT INTO articulo (id_articulo, descripcion, precio, peso, ciudad) VALUES ('A2', 'Articulo2', 200, null, 'Tandil');

INSERT INTO ENVIOS500 VALUES ('P1', 'A1', 500);
INSERT INTO ENVIOS500 VALUES ('P2', 'A2', 300);
UPDATE ENVIOS500 SET cantidad=100 WHERE id_proveedor= 'P1';
UPDATE ENVIOS500 SET cantidad=1000 WHERE id_proveedor= 'P2';
INSERT INTO ENVIOS500 VALUES ('P1', 'A3', 700);

DELETE from envio;