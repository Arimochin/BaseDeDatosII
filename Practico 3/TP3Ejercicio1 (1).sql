CREATE OR REPLACE TRIGGER ProveeSucLocalidad
   BEFORE INSERT OR UPDATE OF cod_suc, nro_prov
   ON provee
   FOR EACH ROW
   EXECUTE FUNCTION ProveeSucLocalidad();

CREATE OR REPLACE FUNCTION fn_tr_proveedor()
RETURNS TRIGGER AS $$
    DECLARE
        localProv proveedor.localidad%type;
    BEGIN
        IF (EXISTS (SELECT 1
                    FROM proveedor p
                    WHERE p.nro_prov IN (SELECT pv.nro_prov
                                         FROM provee pv JOIN sucursal s USING(cod_suc)
                                         WHERE new.localidad <> s.localidad))) THEN
            RAISE EXCEPTION 'El proveedor debe proveer a sucursales de su misma localidad';
        end if;
        RETURN NEW;
    END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER tr_proveedor
    BEFORE UPDATE OF localidad
    ON proveedor
    FOR EACH ROW
    EXECUTE FUNCTION fn_tr_proveedor();

CREATE OR REPLACE FUNCTION fn_tr_sucursal()
RETURNS TRIGGER AS $$
    BEGIN
        IF (EXISTS (SELECT 1
                    FROM sucursal s
                    WHERE s.cod_suc IN (SELECT pv.cod_suc
                                        FROM provee pv JOIN proveedor p USING(nro_prov)
                                        WHERE new.localidad <> p.localidad))) THEN
            RAISE EXCEPTION 'Si la sucursal cambia de localidad no la puede proveer proveedores de otra ciudad';
        end if;
    END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER tr_sucursal
    BEFORE UPDATE
    ON sucursal
    FOR EACH ROW
    EXECUTE FUNCTION fn_tr_sucursal();



CREATE OR REPLACE FUNCTION ProveeSucLocalidad()
RETURNS TRIGGER AS $$
   DECLARE
       localProv proveedor.localidad%type;
       localSuc sucursal.localidad%type;
    BEGIN
        SELECT localidad INTO localProv FROM proveedor WHERE nro_prov = new.nro_prov;
        SELECT localidad INTO localSuc FROM sucursal WHERE cod_suc = new.cod_suc;
        IF ( (SELECT localidad FROM proveedor WHERE nro_prov = new.nro_prov) != localSuc
            OR (SELECT localidad FROM sucursal WHERE cod_suc = new.cod_suc) != localProv ) THEN
            RAISE EXCEPTION 'Un proveedor no puede proveer a un sucursal que no es de su ciudad';
        end if;
        RETURN NEW;
   END;
$$ LANGUAGE 'plpgsql';

--Sentencia para la declarativa
SELECT p.nro_prov
FROM proveedor p JOIN provee pv USING(nro_prov)
                JOIN sucursal s USING(cod_suc)
WHERE p.localidad <> s.localidad;

-- Opcion para poner dentro del IF de la funcion para tabla provee
SELECT localidad INTO localProv FROM proveedor;
        SELECT localidad INTO localSuc FROM sucursal;
        IF ( (SELECT localidad FROM proveedor WHERE nro_prov = new.nro_prov) != localSuc
            OR (SELECT localidad FROM sucursal WHERE cod_suc = new.cod_suc) != localProv )
            THEN
            RAISE EXCEPTION 'Un proveedor no puede proveer a un sucursal que no es de su ciudad';
        end if;
        RETURN NEW;

-- Opcion para poner el IF de la funcion para tabla provee
IF (EXISTS(SELECT 1
                FROM proveedor p JOIN provee pv USING(nro_prov)
                JOIN sucursal s USING(cod_suc)
                WHERE p.localidad <> s.localidad) ) THEN
        RAISE EXCEPTION 'Hay proveedor que provee a sucursal que no es su ciudad';
        END IF;
        RETURN NEW;

-- Valores de prueba
INSERT INTO proveedor values (1, 'Manuel', 'General Paz', 'Olavarria', null);
INSERT INTO sucursal values (1, 'Los Tamariscos', 'Olavarria');
INSERT INTO proveedor values (2, 'Josesito', 'España', 'Tandil', null);
INSERT INTO sucursal values (2, 'La Fattoria', 'Tandil');
INSERT INTO producto values (1, null, null, 12);

DROP TRIGGER ProveeSucLocalidad on provee;
DROP FUNCTION proveesuclocalidad() ;

-- Ver tablas
SELECT * FROM proveedor;
SELECT * FROM sucursal;
SELECT * FROM provee;


INSERT INTO provee values (1, 1, 1); -- Inserto proveedor y sucursal de la misma localidad
DELETE FROM provee ;
UPDATE provee set nro_prov = 1 where nro_prov = 1;
UPDATE provee set cod_suc = 2 where nro_prov = 1; -- Salta trigger de tabla provee

UPDATE proveedor set localidad = 'Tandil' where nro_prov = 1; -- Salta trigger de tabla proveedor

UPDATE sucursal set localidad = 'Tandil' where cod_suc = 1; -- Salta trigger de tabla sucursal

---------------------------------------------------------------
-- 3.a)

CREATE OR REPLACE FUNCTION fn_tr_provee()
RETURNS TRIGGER AS $$
    BEGIN
        IF ((SELECT count(*)
             FROM provee pv
             WHERE nro_prov = new.nro_prov AND cod_suc = new.cod_suc) >= 20) THEN
            RAISE EXCEPTION 'Supera la cant maxima de productos que un proveedor puede proveer a la misma sucursal';
        END IF;
        RETURN NEW;
    END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER tr_provee
    BEFORE INSERT OR UPDATE OF cod_producto, nro_prov, cod_suc
    ON provee
    FOR EACH ROW
    EXECUTE FUNCTION fn_tr_provee();

INSERT INTO provee values (1,2,2);

INSERT INTO producto values (2, null, null, 4);
INSERT INTO producto values (3, null, null, 12);
INSERT INTO producto values (4, null, null, 12);
INSERT INTO producto values (5, null, null, 12);
INSERT INTO producto values (6, null, null, 12);
INSERT INTO producto values (7, null, null, 12);
INSERT INTO producto values (8, null, null, 12);
INSERT INTO producto values (9, null, null, 12);
INSERT INTO producto values (10, null, null, 12);
INSERT INTO producto values (11, null, null, 12);
INSERT INTO producto values (12, null, null, 12);
INSERT INTO producto values (13, null, null, 12);
INSERT INTO producto values (14, null, null, 12);
INSERT INTO producto values (15, null, null, 12);
INSERT INTO producto values (16, null, null, 12);
INSERT INTO producto values (17, null, null, 12);
INSERT INTO producto values (18, null, null, 12);
INSERT INTO producto values (19, null, null, 12);
INSERT INTO producto values (20, null, null, 12);
INSERT INTO producto values (21, null, null, 12);
INSERT INTO producto values (22, null, null, 12);

INSERT INTO provee values (2, 1, 1);
INSERT INTO provee values (3, 1, 1);
INSERT INTO provee values (4, 1, 1);
INSERT INTO provee values (5, 1, 1);
INSERT INTO provee values (6, 1, 1);
INSERT INTO provee values (7, 1, 1);
INSERT INTO provee values (8, 1, 1);
INSERT INTO provee values (9, 1, 1);
INSERT INTO provee values (10, 1, 1);
INSERT INTO provee values (11, 1, 1);
INSERT INTO provee values (12, 1, 1);
INSERT INTO provee values (13, 1, 1);
INSERT INTO provee values (14, 1, 1);
INSERT INTO provee values (15, 1, 1);
INSERT INTO provee values (16, 1, 1);
INSERT INTO provee values (17, 1, 1);
INSERT INTO provee values (18, 1, 1);
INSERT INTO provee values (19, 1, 1);
INSERT INTO provee values (20, 1, 1);
INSERT INTO provee values (21, 1, 1);
INSERT INTO provee values (22, 1, 1);

DELETE FROM provee where cod_producto = 21;
DELETE FROM provee where cod_producto = 22;

SELECT * from provee;