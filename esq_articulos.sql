CREATE TABLE ARTICULO (
    id_articulo int  NOT NULL,
    titulo varchar(100)  NOT NULL,
    autor varchar(50)  NOT NULL,
    nacionalidad varchar(50)  NOT NULL,
    fecha_pub date  NULL,
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

