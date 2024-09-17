
CREATE TABLE CLIENTE (
    Zona char(2)  NOT NULL,
    NroC int  NOT NULL,
    Apell_nombre varchar(50)  NOT NULL,
    Ciudad varchar(20)  NOT NULL,
    CONSTRAINT CLIENTE_pk PRIMARY KEY (Zona,NroC)
);

CREATE TABLE INSTALACION (
    Zona char(2)  NOT NULL,
    NroC int  NOT NULL,
    idServ int  NOT NULL,
    fecha_instalacion date  NOT NULL,
    cantHoras int  NOT NULL,
    tarea varchar(50)  NOT NULL,
    CONSTRAINT INSTALACION_pk PRIMARY KEY (Zona,NroC,idServ),
    CONSTRAINT FK_Instalacion_Servicio FOREIGN KEY (idServ)
                         REFERENCES SERVICIO (idServ)
                         ON UPDATE RESTRICT
                         ON DELETE RESTRICT,
    CONSTRAINT FK_Instalacion_Cliente FOREIGN KEY (Zona, NroC)
                         REFERENCES CLIENTE (Zona, NroC)
                         ON UPDATE CASCADE
                         ON DELETE RESTRICT
);



CREATE TABLE REFERENCIA (
    idServ int  NOT NULL,
    motivo char(10)  NOT NULL,
    comentario varchar(80)  NOT NULL,
    Zona char(2)  NULL,
    NroC int  NULL,
    CONSTRAINT REFERENCIA_pk PRIMARY KEY (idServ,motivo),
    CONSTRAINT FK_Referencia_Sercicio FOREIGN KEY (idServ)
                        REFERENCES SERVICIO (idServ)
                        ON UPDATE RESTRICT
                        ON DELETE CASCADE,
    CONSTRAINT FK_Referencia_Cliente FOREIGN KEY (Zona, NroC)
                        REFERENCES CLIENTE (Zona, NroC)
                        ON UPDATE RESTRICT
                        ON DELETE SET NULL
);

CREATE TABLE SERVICIO (
    idServ int  NOT NULL,
    nombreServ varchar(50)  NOT NULL,
    anio_comienzo int  NOT NULL,
    anio_fin int  NULL,
    tipoServ char(10)  NOT NULL,
    CONSTRAINT SERVICIO_pk PRIMARY KEY (idServ)
);