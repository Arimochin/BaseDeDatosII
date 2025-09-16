CREATE OR REPLACE FUNCTION fn_maxProdSuc()
RETURNS TRIGGER AS $$
    BEGIN
        if (   (SELECT count(*)
                FROM provee
                WHERE nro_prov = new.nro_prov AND cod_suc = new.cod_suc) >= 20 )
        THEN
            RAISE EXCEPTION 'Un proveedor solo puede proveer hasta 20 productos a una misma sucursal' ;
        end if;
    RETURN new;
END
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER tr_maxProdSuc
BEFORE INSERT OR UPDATE OF nro_prov, cod_suc
ON provee
FOR EACH ROW
EXECUTE FUNCTION fn_maxProdSuc();

INSERT INTO producto (cod_producto, presentacion, descripcion, tipo) VALUES (1, null, null, 1);
INSERT INTO proveedor (nro_prov, nombre, direccion, localidad, fecha_nac) VALUES (1, 'Prov1', 'General Paz', 'Olavarria', null);
INSERT INTO sucursal (cod_suc, nombre, localidad) VALUES (1, 'Suc1', 'Tandil');
INSERT INTO provee (cod_producto, nro_prov, cod_suc) VALUES (1, 1, 1);

INSERT INTO proveedor (nro_prov, nombre, direccion, localidad, fecha_nac) VALUES (2, 'Prov2', 'Dir2', 'Tandil', null);
INSERT INTO provee (cod_producto, nro_prov, cod_suc) VALUES (1, 2, 1);


INSERT INTO producto (cod_producto, presentacion, descripcion, tipo) VALUES (2, null, null, 1);
INSERT INTO producto (cod_producto, presentacion, descripcion, tipo) VALUES (3, null, null, 1);
INSERT INTO producto (cod_producto, presentacion, descripcion, tipo) VALUES (4, null, null, 1);
INSERT INTO producto (cod_producto, presentacion, descripcion, tipo) VALUES (5, null, null, 1);
INSERT INTO producto (cod_producto, presentacion, descripcion, tipo) VALUES (6, null, null, 1);
INSERT INTO producto (cod_producto, presentacion, descripcion, tipo) VALUES (7, null, null, 1);
INSERT INTO producto (cod_producto, presentacion, descripcion, tipo) VALUES (8, null, null, 1);
INSERT INTO producto (cod_producto, presentacion, descripcion, tipo) VALUES (9, null, null, 1);
INSERT INTO producto (cod_producto, presentacion, descripcion, tipo) VALUES (10, null, null, 1);
INSERT INTO producto (cod_producto, presentacion, descripcion, tipo) VALUES (11, null, null, 1);
INSERT INTO producto (cod_producto, presentacion, descripcion, tipo) VALUES (12, null, null, 1);
INSERT INTO producto (cod_producto, presentacion, descripcion, tipo) VALUES (13, null, null, 1);
INSERT INTO producto (cod_producto, presentacion, descripcion, tipo) VALUES (14, null, null, 1);
INSERT INTO producto (cod_producto, presentacion, descripcion, tipo) VALUES (15, null, null, 1);
INSERT INTO producto (cod_producto, presentacion, descripcion, tipo) VALUES (16, null, null, 1);
INSERT INTO producto (cod_producto, presentacion, descripcion, tipo) VALUES (17, null, null, 1);
INSERT INTO producto (cod_producto, presentacion, descripcion, tipo) VALUES (18, null, null, 1);
INSERT INTO producto (cod_producto, presentacion, descripcion, tipo) VALUES (19, null, null, 1);
INSERT INTO producto (cod_producto, presentacion, descripcion, tipo) VALUES (20, null, null, 1);
INSERT INTO producto (cod_producto, presentacion, descripcion, tipo) VALUES (21, null, null, 1);

INSERT INTO provee (cod_producto, nro_prov, cod_suc) VALUES (2, 2, 1);
INSERT INTO provee (cod_producto, nro_prov, cod_suc) VALUES (3, 2, 1);
INSERT INTO provee (cod_producto, nro_prov, cod_suc) VALUES (4, 2, 1);
INSERT INTO provee (cod_producto, nro_prov, cod_suc) VALUES (5, 2, 1);
INSERT INTO provee (cod_producto, nro_prov, cod_suc) VALUES (6, 2, 1);
INSERT INTO provee (cod_producto, nro_prov, cod_suc) VALUES (7, 2, 1);
INSERT INTO provee (cod_producto, nro_prov, cod_suc) VALUES (8, 2, 1);
INSERT INTO provee (cod_producto, nro_prov, cod_suc) VALUES (9, 2, 1);
INSERT INTO provee (cod_producto, nro_prov, cod_suc) VALUES (10, 2, 1);
INSERT INTO provee (cod_producto, nro_prov, cod_suc) VALUES (11, 2, 1);
INSERT INTO provee (cod_producto, nro_prov, cod_suc) VALUES (12, 2, 1);
INSERT INTO provee (cod_producto, nro_prov, cod_suc) VALUES (13, 2, 1);
INSERT INTO provee (cod_producto, nro_prov, cod_suc) VALUES (14, 2, 1);
INSERT INTO provee (cod_producto, nro_prov, cod_suc) VALUES (15, 2, 1);
INSERT INTO provee (cod_producto, nro_prov, cod_suc) VALUES (16, 2, 1);
INSERT INTO provee (cod_producto, nro_prov, cod_suc) VALUES (17, 2, 1);
INSERT INTO provee (cod_producto, nro_prov, cod_suc) VALUES (18, 2, 1);
INSERT INTO provee (cod_producto, nro_prov, cod_suc) VALUES (19, 2, 1);
INSERT INTO provee (cod_producto, nro_prov, cod_suc) VALUES (20, 2, 1);

INSERT INTO provee (cod_producto, nro_prov, cod_suc) VALUES (21, 2, 1);


