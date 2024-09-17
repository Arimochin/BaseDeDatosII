CREATE TABLE ARTICULO (
    id_articulo int  NOT NULL,
    titulo varchar(100)  NOT NULL,
    autor varchar(50)  NOT NULL,
    nacionalidad Nacionalidad  NOT NULL,
    fecha_pub Fecha_pub  NULL,
    CONSTRAINT ARTICULO_pk PRIMARY KEY (id_articulo)
);

CREATE TABLE CONTIENE (
    id_articulo int  NOT NULL,
    idioma varchar(50)  NOT NULL,
    cod_palabra int  NOT NULL,
    nro_seccion int  NOT NULL,
    CONSTRAINT CONTIENE_pk PRIMARY KEY (id_articulo,cod_palabra,idioma)
);

CREATE TABLE PALABRA (
    idioma varchar(50)  NOT NULL,
    cod_palabra int  NOT NULL,
    descripcion varchar(100)  NOT NULL,
    CONSTRAINT PALABRA_pk PRIMARY KEY (idioma,cod_palabra)
);

ALTER TABLE CONTIENE ADD CONSTRAINT FK_CONTIENE_ARTICULO
    FOREIGN KEY (id_articulo)
    REFERENCES ARTICULO (id_articulo)
;

ALTER TABLE CONTIENE ADD CONSTRAINT FK_CONTIENE_PALABRA
    FOREIGN KEY (idioma, cod_palabra)
    REFERENCES PALABRA (idioma, cod_palabra)
;

--Controlar que las nacionalidades sean 'Argentina', 'Española', 'Inglesa' o 'Chilena'.
CREATE DOMAIN Nacionalidad
AS varchar(50)
CONSTRAINT nacion
CHECK ( value = 'Argentina' OR value = 'Española' OR value = 'Inglesa' OR value = 'Chilena' );

--Para las fechas de publicaciones se debe considerar que sean fechas posteriores o iguales al 2010.
CREATE DOMAIN Fecha_pub
AS date
CONSTRAINT fechaMayorQue2010
CHECK ( extract(year from VALUE) >= 2010 );

--Los artículos publicados luego del año 2020 no deben ser de nacionalidad Inglesa.
ALTER TABLE ARTICULO
ADD CONSTRAINT publicacion2020NoInglesa
CHECK ( extract(year from fecha_pub) <= 2020 OR (extract(year from fecha_pub) > 2020 AND nacionalidad <> 'Inglesa') )

--Sólo se pueden publicar artículos argentinos que contengan hasta 10 palabras claves.
CREATE ASSERTION articulos_arg_10_pal
       CHECK (NOT EXISTS (SELECT id_articulo
                        FROM articulo JOIN contiene USING (id_articulo)
                        WHERE nacionalidad = 'Argentina'
                        GROUP BY id_articulo
                        HAVING count(cod_palabra) > 10))

SELECT id_articulo
FROM articulo JOIN contiene USING (id_articulo)
WHERE nacionalidad = 'Argentina'
GROUP BY id_articulo
HAVING count(cod_palabra) > 10


