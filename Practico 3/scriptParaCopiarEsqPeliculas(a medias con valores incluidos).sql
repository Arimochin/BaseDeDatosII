---- Scrip para traer el esquema peliculas

CREATE TABLE entrega AS
    SELECT * FROM unc_esq_peliculas.entrega;

CREATE TABLE renglon_entrega AS
    SELECT * FROM unc_esq_peliculas.renglon_entrega;

CREATE TABLE pelicula AS
    SELECT * FROM unc_esq_peliculas.pelicula;

CREATE TABLE distribuidor AS
    SELECT * FROM unc_esq_peliculas.distribuidor;

CREATE TABLE video AS
    SELECT * FROM unc_esq_peliculas.video;

CREATE TABLE empleado AS
    SELECT * FROM unc_esq_peliculas.empleado;

CREATE TABLE departamento AS
    SELECT * FROM unc_esq_peliculas.departamento;

CREATE TABLE tarea AS
    SELECT * FROM unc_esq_peliculas.tarea;

ALTER TABLE entrega ADD CONSTRAINT PK_entrega PRIMARY KEY (nro_entrega);
ALTER TABLE renglon_entrega ADD CONSTRAINT PK_renglon_entrega PRIMARY KEY (nro_entrega, codigo_pelicula);
ALTER TABLE pelicula ADD CONSTRAINT PK_pelicula PRIMARY KEY (codigo_pelicula);
ALTER TABLE distribuidor ADD CONSTRAINT PK_distribuidor PRIMARY KEY (id_distribuidor);
ALTER TABLE video ADD CONSTRAINT PK_video PRIMARY KEY (id_video);
ALTER TABLE empleado ADD CONSTRAINT PK_empleado PRIMARY KEY (id_empleado);
ALTER TABLE departamento ADD CONSTRAINT PK_departamentos PRIMARY KEY (id_distribuidor, id_departamento);
ALTER TABLE tarea ADD CONSTRAINT PK_tarea PRIMARY KEY (id_tarea);

ALTER TABLE entrega ADD CONSTRAINT FK_entrega_distribuidor FOREIGN KEY (id_distribuidor) REFERENCES distribuidor (id_distribuidor),
                    ADD CONSTRAINT FK_entrega_video FOREIGN KEY (id_video) REFERENCES video (id_video);
ALTER TABLE renglon_entrega ADD CONSTRAINT FK_renglon_entrega FOREIGN KEY (nro_entrega) REFERENCES entrega (nro_entrega),
                            ADD CONSTRAINT FK_renglon_pelicula FOREIGN KEY (codigo_pelicula) REFERENCES pelicula (codigo_pelicula);
ALTER TABLE empleado ADD CONSTRAINT FK_empleado_tarea FOREIGN KEY (id_tarea) REFERENCES tarea(id_tarea),
                     ADD CONSTRAINT FK_empleado_departamento FOREIGN KEY (id_distribuidor, id_departamento) REFERENCES departamento,
                     ADD CONSTRAINT FK_empleado_empleado FOREIGN KEY (id_jefe) REFERENCES empleado (id_empleado);
ALTER TABLE departamento ADD CONSTRAINT FK_departamento_empleado FOREIGN KEY (jefe_departamento) REFERENCES empleado (id_empleado);