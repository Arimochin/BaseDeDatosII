/*
CREATE OR REPLACE FUNCTION fn_mismaLocalidad()
RETURNS TRIGGER AS $$
BEGIN
	IF ( EXISTS ( SELECT 1
	              FROM proveedor p JOIN provee pv USING (nro_prov)
	                               JOIN sucursal s USING (cod_suc)
	              WHERE new.cod_suc = pv.cod_suc
	                AND new.nro_prov = pv.nro_prov
	                AND p.localidad != s.localidad ) )
	THEN RAISE EXCEPTION 'Un proveedor solo puede proveer a una sucursal en su misma localidad';
    END IF;
    RETURN new;
END
$$ LANGUAGE 'plpgsql';
*/

CREATE OR REPLACE FUNCTION fn_mismaLocalidad()
RETURNS TRIGGER AS $$
DECLARE
    loc_prov proveedor.localidad%type;
    loc_suc sucursal.localidad%type;
BEGIN


    IF (tg_table_name = 'proveedor') THEN

        IF ( EXISTS(
            SELECT
            FROM provee join sucursal USING (cod_suc)
            WHERE provee.nro_prov = new.nro_prov
            AND new.localidad != sucursal.localidad
        ) ) THEN
            RAISE EXCEPTION 'La localidad del proveedor debe ser igual a la localidad de la sucursal que provee ';
        end if;


        --IF (new.localidad != loc_suc) THEN
        --    RAISE EXCEPTION 'La localidad del proveedor debe ser igual a la localidad de la sucursal que provee ';
        --end if;
    end if;

    IF(tg_table_name = 'sucursal') THEN
        IF ( EXISTS(
            SELECT
            FROM provee join proveedor USING (nro_prov)
            WHERE provee.cod_suc = new.cod_suc
            AND new.localidad != proveedor.localidad
        ) ) THEN
            RAISE EXCEPTION 'La localidad de la sucursal debe ser igual a la localidad del proveedor';
        end if;

        --IF (new.localidad != loc_prov) THEN
        --    RAISE EXCEPTION 'La localidad de la sucursal debe ser igual a la localidad del proveedor';
        --end if;
    end if;

    IF (tg_table_name = 'provee') THEN
        SELECT localidad into loc_prov
        FROM proveedor
        WHERE nro_prov = new.nro_prov;

        SELECT localidad into loc_suc
        FROM sucursal
        WHERE cod_suc = new.cod_suc;

        IF (loc_prov != loc_suc) THEN
            RAISE EXCEPTION 'Las localidades de sucursal y proveedor deben ser iguales';
        end if;
    end if;

    RETURN new;

END
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER tr_mismaLocalidad1
BEFORE UPDATE OF localidad
ON proveedor
FOR EACH ROW
EXECUTE FUNCTION fn_mismaLocalidad();

CREATE OR REPLACE TRIGGER tr_mismaLocalidad2
BEFORE UPDATE OF localidad
ON sucursal
FOR EACH ROW
EXECUTE FUNCTION fn_mismaLocalidad();

CREATE OR REPLACE TRIGGER tr_mismaLocalidad3
BEFORE INSERT OR UPDATE OF nro_prov, cod_suc
ON provee
FOR EACH ROW
EXECUTE FUNCTION fn_mismaLocalidad();

INSERT INTO producto (cod_producto, presentacion, descripcion, tipo) VALUES (1, null, null, 1);
INSERT INTO proveedor (nro_prov, nombre, direccion, localidad, fecha_nac) VALUES (1, 'Prov1', 'General Paz', 'Olavarria', null);
INSERT INTO sucursal (cod_suc, nombre, localidad) VALUES (1, 'Suc1', 'Tandil');
INSERT INTO provee (cod_producto, nro_prov, cod_suc) VALUES (1, 1, 1);

INSERT INTO proveedor (nro_prov, nombre, direccion, localidad, fecha_nac) VALUES (2, 'Prov2', 'Dir2', 'Tandil', null);
INSERT INTO provee (cod_producto, nro_prov, cod_suc) VALUES (1, 2, 1);

UPDATE proveedor set localidad = 'Olavarria' where nro_prov = 2;
UPDATE sucursal set localidad = 'Olavarria' where cod_suc = 1;
UPDATE provee set nro_prov = 1 where cod_suc = 1;
