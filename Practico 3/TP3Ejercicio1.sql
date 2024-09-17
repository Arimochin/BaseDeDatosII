CREATE TABLE PRODUCTO (
    cod_producto int  NOT NULL,
    presentacion varchar(50)  NULL,
    descripcion varchar(50)  NULL,
    tipo int  NOT NULL,
    CONSTRAINT PRODUCTO_pk PRIMARY KEY (cod_producto)
);

CREATE TABLE PROVEE (
    cod_producto int  NOT NULL,
    nro_prov int  NOT NULL,
    cod_suc int  NOT NULL,
    CONSTRAINT PROVEE_pk PRIMARY KEY (cod_producto,nro_prov)
);

CREATE TABLE PROVEEDOR (
    nro_prov int  NOT NULL,
    nombre varchar(50)  NOT NULL,
    direccion varchar(50)  NOT NULL,
    localidad varchar(30)  NOT NULL,
    fecha_nac date  NULL,
    CONSTRAINT PROVEEDOR_pk PRIMARY KEY (nro_prov)
);

CREATE TABLE SUCURSAL (
    cod_suc int  NOT NULL,
    nombre varchar(50)  NOT NULL,
    localidad varchar(30)  NOT NULL,
    CONSTRAINT SUCURSAL_pk PRIMARY KEY (cod_suc)
);

ALTER TABLE PROVEE ADD CONSTRAINT PROVEE_PRODUCTO
    FOREIGN KEY (cod_producto)
    REFERENCES PRODUCTO (cod_producto)
;

ALTER TABLE PROVEE ADD CONSTRAINT PROVEE_PROVEEDOR
    FOREIGN KEY (nro_prov)
    REFERENCES PROVEEDOR (nro_prov)
;

ALTER TABLE PROVEE ADD CONSTRAINT PROVEE_SUCURSAL
    FOREIGN KEY (cod_suc)
    REFERENCES SUCURSAL (cod_suc)
;

--
CREATE TRIGGER ProveeSucLocalidad
    BEFORE UPDATE
    ON proveedor
    FOR STATEMENT
    EXECUTE FUNCTION ;

CREATE FUNCTION ProveeSucLocalidad()
RETURNS TRIGGER AS $$
    BEGIN

    END;
$$ LANGUAGE 'plpgsql';


SELECT p.nro_prov
FROM proveedor p JOIN provee pv USING(nro_prov)
                 JOIN sucursal s USING(cod_suc)
WHERE p.localidad <> s.localidad;