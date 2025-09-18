CREATE TABLE ciudad_pel (
    id_ciudad numeric(6,0) NOT NULL,
    nombre_ciudad character varying(100),
    id_pais character(2),
    CONSTRAINT ciudad_pel_id_ciudad_check CHECK ((id_ciudad IS NOT NULL)),
    CONSTRAINT ciudad_pel_id_pais_check CHECK ((id_pais IS NOT NULL)),
    CONSTRAINT ciudad_pel_nombre_ciudad_check CHECK ((nombre_ciudad IS NOT NULL))
)
WITH (autovacuum_enabled='true');


CREATE TABLE pais_pel
 (
    id_pais character(2) NOT NULL,
    nombre_pais character varying(40),
    CONSTRAINT pais_pel_id_pais_check CHECK ((id_pais IS NOT NULL))
)
WITH (autovacuum_enabled='true');


CREATE TABLE internacional_pel (
    id_distribuidor_pel numeric(5,0) NOT NULL,
    codigo_pais character varying(5),
    CONSTRAINT internacional_pel_codigo_pais_check CHECK ((codigo_pais IS NOT NULL)),
    CONSTRAINT internacional_pel_id_distribuidor_pel_check CHECK ((id_distribuidor_pel IS NOT NULL))
)
WITH (autovacuum_enabled='true');


CREATE TABLE nacional_pel (
    id_distribuidor_pel numeric(5,0) NOT NULL,
    nro_inscripcion numeric(8,0),
    encargado character varying(60),
    id_distrib_mayorista numeric(5,0),
    CONSTRAINT nacional_pel_encargado_check CHECK ((encargado IS NOT NULL)),
    CONSTRAINT nacional_pel_id_distribuidor_pel_check CHECK ((id_distribuidor_pel IS NOT NULL)),
    CONSTRAINT nacional_pel_nro_inscripcion_check CHECK ((nro_inscripcion IS NOT NULL))
)
WITH (autovacuum_enabled='true');


CREATE TABLE departamento_pel (
    id_departamento numeric(4,0) NOT NULL,
    id_distribuidor_pel numeric(5,0) NOT NULL,
    nombre character varying(30),
    calle character varying(40),
    numero numeric(6,0),
    id_ciudad numeric(6,0),
    jefe_departamento numeric(6,0),
    CONSTRAINT departamento_pel_id_ciudad_check CHECK ((id_ciudad IS NOT NULL)),
    CONSTRAINT departamento_pel_id_departamento_check CHECK ((id_departamento IS NOT NULL)),
    CONSTRAINT departamento_pel_id_distribuidor_pel_check CHECK ((id_distribuidor_pel IS NOT NULL)),
    CONSTRAINT departamento_pel_jefe_departamento_check CHECK ((jefe_departamento IS NOT NULL)),
    CONSTRAINT departamento_pel_nombre_departamento_check CHECK ((nombre IS NOT NULL))
)
WITH (autovacuum_enabled='true');


CREATE TABLE empleado_pel (
    id_empleado numeric(6,0) NOT NULL,
    nombre character varying(30),
    apellido character varying(30),
    porc_comision numeric(6,2),
    sueldo numeric(8,2),
    e_mail character varying(120),
    fecha_nacimiento date,
    telefono character varying(20),
    id_tarea character varying(10),
    id_departamento numeric(4,0),
    id_distribuidor_pel numeric(5,0),
    id_jefe numeric(6,0),
    CONSTRAINT empleado_pel_apellido_check CHECK ((apellido IS NOT NULL)),
    CONSTRAINT empleado_pel_e_mail_check CHECK ((e_mail IS NOT NULL)),
    CONSTRAINT empleado_pel_fecha_nacimiento_check CHECK ((fecha_nacimiento IS NOT NULL)),
    CONSTRAINT empleado_pel_id_empleado_check CHECK ((id_empleado IS NOT NULL)),
    CONSTRAINT empleado_pel_id_tarea_check CHECK ((id_tarea IS NOT NULL))
)
WITH (autovacuum_enabled='true');


CREATE TABLE pelicula_pel (
    codigo_pelicula numeric(5,0) NOT NULL,
    titulo character varying(60),
    idioma character varying(20),
    formato character varying(20),
    genero character varying(30),
    codigo_productora character varying(6),
    CONSTRAINT pelicula_pel_codigo_pelicula_check CHECK ((codigo_pelicula IS NOT NULL)),
    CONSTRAINT pelicula_pel_codigo_productora_check CHECK ((codigo_productora IS NOT NULL)),
    CONSTRAINT pelicula_pel_formato_check CHECK ((formato IS NOT NULL)),
    CONSTRAINT pelicula_pel_genero_check CHECK ((genero IS NOT NULL)),
    CONSTRAINT pelicula_pel_idioma_check CHECK ((idioma IS NOT NULL)),
    CONSTRAINT pelicula_pel_titulo_check CHECK ((titulo IS NOT NULL))
)
WITH (autovacuum_enabled='true');


CREATE TABLE renglon_entrega_pel (
    nro_entrega numeric(10,0) NOT NULL,
    codigo_pelicula numeric(5,0) NOT NULL,
    cantidad numeric(5,0),
    CONSTRAINT renglon_entrega_pel_cantidad_check CHECK ((cantidad IS NOT NULL)),
    CONSTRAINT renglon_entrega_pel_codigo_pelicula_check CHECK ((codigo_pelicula IS NOT NULL)),
    CONSTRAINT renglon_entrega_pel_nro_entrega_check CHECK ((nro_entrega IS NOT NULL))
)
WITH (autovacuum_enabled='true');


CREATE TABLE distribuidor_pel (
    id_distribuidor_pel numeric(5,0) NOT NULL,
    nombre character varying(80),
    direccion character varying(120),
    telefono character varying(20),
    tipo character(1),
    CONSTRAINT distribuidor_pel_direccion_check CHECK ((direccion IS NOT NULL)),
    CONSTRAINT distribuidor_pel_id_distribuidor_pel_check CHECK ((id_distribuidor_pel IS NOT NULL)),
    CONSTRAINT distribuidor_pel_nombre_check CHECK ((nombre IS NOT NULL)),
    CONSTRAINT distribuidor_pel_tipo_check CHECK ((tipo IS NOT NULL))
)
WITH (autovacuum_enabled='true');



CREATE TABLE empresa_productora_pel (
    codigo_productora character varying(6) NOT NULL,
    nombre_productora character varying(60),
    id_ciudad numeric(6,0),
    CONSTRAINT empresa_productora_pel_codigo_productora_check CHECK ((codigo_productora IS NOT NULL)),
    CONSTRAINT empresa_productora_pel_nombre_productora_check CHECK ((nombre_productora IS NOT NULL))
)
WITH (autovacuum_enabled='true');

CREATE TABLE entrega_pel (
    nro_entrega numeric(10,0) NOT NULL,
    fecha_entrega date,
    id_video numeric(5,0),
    id_distribuidor_pel numeric(5,0),
    CONSTRAINT entrega_pel_fecha_entrega_check CHECK ((fecha_entrega IS NOT NULL)),
    CONSTRAINT entrega_pel_id_distribuidor_pel_check CHECK ((id_distribuidor_pel IS NOT NULL)),
    CONSTRAINT entrega_pel_id_video_check CHECK ((id_video IS NOT NULL)),
    CONSTRAINT entrega_pel_nro_entrega_check CHECK ((nro_entrega IS NOT NULL))
)
WITH (autovacuum_enabled='true');


CREATE TABLE tarea_pel (
    id_tarea character varying(10) NOT NULL,
    nombre_tarea character varying(35),
    sueldo_maximo numeric(6,0),
    sueldo_minimo numeric(6,0),
    CONSTRAINT tarea_pel_id_tarea_check CHECK ((id_tarea IS NOT NULL)),
    CONSTRAINT tarea_pel_nombre_tarea_check CHECK ((nombre_tarea IS NOT NULL)),
    CONSTRAINT tarea_pel_sueldo_maximo_check CHECK ((sueldo_maximo IS NOT NULL)),
    CONSTRAINT tarea_pel_sueldo_minimo_check CHECK ((sueldo_minimo IS NOT NULL))
)
WITH (autovacuum_enabled='true');


CREATE TABLE video_pel (
    id_video numeric(5,0) NOT NULL,
    razon_social character varying(60),
    direccion character varying(80),
    telefono character varying(15),
    propietario character varying(60),
    CONSTRAINT video_pel_direccion_check CHECK ((direccion IS NOT NULL)),
    CONSTRAINT video_pel_id_video_check CHECK ((id_video IS NOT NULL)),
    CONSTRAINT video_pel_propietario_check CHECK ((propietario IS NOT NULL)),
    CONSTRAINT video_pel_razon_social_check CHECK ((razon_social IS NOT NULL))
)
WITH (autovacuum_enabled='true');

-- Insertar en ciudad_pel desde ciudad_pel
INSERT INTO ciudad_pel (SELECT * FROM unc_esq_peliculas.ciudad);

-- Insertar en departamento_pel desde departamento_pel
INSERT INTO departamento_pel (SELECT * FROM unc_esq_peliculas.departamento);

-- Insertar en distribuidor_pel desde distribuidor_pel
INSERT INTO distribuidor_pel (SELECT * FROM unc_esq_peliculas.distribuidor);

-- Insertar en empleado_pel desde empleado_pel
INSERT INTO empleado_pel (SELECT * FROM unc_esq_peliculas.empleado);

-- Insertar en empresa_productora_pel desde empresa_productora_pel
INSERT INTO empresa_productora_pel (SELECT * FROM unc_esq_peliculas.empresa_productora);

-- Insertar en entrega_pel desde entrega_pel
INSERT INTO entrega_pel (SELECT * FROM unc_esq_peliculas.entrega);

-- Insertar en internacional_pel desde internacional_pel
INSERT INTO internacional_pel (SELECT * FROM unc_esq_peliculas.internacional);

-- Insertar en nacional_pel desde nacional_pel
INSERT INTO nacional_pel (SELECT * FROM unc_esq_peliculas.nacional);

-- Insertar en pais_pel_desde pais_pel

INSERT INTO pais_pel (SELECT * FROM unc_esq_peliculas.pais);

-- Insertar en pelicula_pel desde pelicula_pel
INSERT INTO pelicula_pel (SELECT * FROM unc_esq_peliculas.pelicula);

-- Insertar en renglon_entrega_pel desde renglon_entrega_pel
INSERT INTO renglon_entrega_pel (SELECT * FROM unc_esq_peliculas.renglon_entrega);

-- Insertar en tarea_pel desde tarea_pel
INSERT INTO tarea_pel (SELECT * FROM unc_esq_peliculas.tarea);

-- Insertar en video_pel desde video_pel
INSERT INTO video_pel (SELECT * FROM unc_esq_peliculas.video);


--
-- Name: ciudad_pel pk_ciudad; Type: CONSTRAINT; Schema: unc_esq_peliculas; Owner: postgres
--

ALTER TABLE ONLY ciudad_pel
    ADD CONSTRAINT pk_ciudad PRIMARY KEY (id_ciudad);


--
-- Name: departamento_pel pk_departamento; Type: CONSTRAINT; Schema: unc_esq_peliculas; Owner: postgres
--

ALTER TABLE ONLY departamento_pel
    ADD CONSTRAINT pk_departamento PRIMARY KEY (id_distribuidor_pel, id_departamento);


--
-- Name: distribuidor_pel pk_distribuidor_pel; Type: CONSTRAINT; Schema: unc_esq_peliculas; Owner: postgres
--

ALTER TABLE ONLY distribuidor_pel
    ADD CONSTRAINT pk_distribuidor_pel PRIMARY KEY (id_distribuidor_pel);


--
-- Name: empleado_pel pk_empleado; Type: CONSTRAINT; Schema: unc_esq_peliculas; Owner: postgres
--

ALTER TABLE ONLY empleado_pel
    ADD CONSTRAINT pk_empleado PRIMARY KEY (id_empleado);


--
-- Name: empresa_productora_pel pk_empresa_productora; Type: CONSTRAINT; Schema: unc_esq_peliculas; Owner: postgres
--

ALTER TABLE ONLY empresa_productora_pel
    ADD CONSTRAINT pk_empresa_productora PRIMARY KEY (codigo_productora);


--
-- Name: entrega_pel pk_entrega; Type: CONSTRAINT; Schema: unc_esq_peliculas; Owner: postgres
--

ALTER TABLE ONLY entrega_pel
    ADD CONSTRAINT pk_entrega PRIMARY KEY (nro_entrega);


--
-- Name: internacional_pel pk_internacional; Type: CONSTRAINT; Schema: unc_esq_peliculas; Owner: postgres
--

ALTER TABLE ONLY internacional_pel
    ADD CONSTRAINT pk_internacional PRIMARY KEY (id_distribuidor_pel);


--
-- Name: nacional_pel pk_nacional; Type: CONSTRAINT; Schema: unc_esq_peliculas; Owner: postgres
--

ALTER TABLE ONLY nacional_pel
    ADD CONSTRAINT pk_nacional PRIMARY KEY (id_distribuidor_pel);


--
-- Name: pais_pel_pk_pais; Type: CONSTRAINT; Schema: unc_esq_peliculas; Owner: postgres
--

ALTER TABLE ONLY pais_pel

    ADD CONSTRAINT pk_pais_pel PRIMARY KEY (id_pais);


--
-- Name: pelicula_pel pk_pelicula; Type: CONSTRAINT; Schema: unc_esq_peliculas; Owner: postgres
--

ALTER TABLE ONLY pelicula_pel
    ADD CONSTRAINT pk_pelicula PRIMARY KEY (codigo_pelicula);


--
-- Name: renglon_entrega_pel pk_renglon_entrega; Type: CONSTRAINT; Schema: unc_esq_peliculas; Owner: postgres
--

ALTER TABLE ONLY renglon_entrega_pel
    ADD CONSTRAINT pk_renglon_entrega PRIMARY KEY (nro_entrega, codigo_pelicula);


--
-- Name: tarea_pel pk_tarea; Type: CONSTRAINT; Schema: unc_esq_peliculas; Owner: postgres
--

ALTER TABLE ONLY tarea_pel
    ADD CONSTRAINT pk_tarea_pel PRIMARY KEY (id_tarea);


--
-- Name: video_pel pk_video; Type: CONSTRAINT; Schema: unc_esq_peliculas; Owner: postgres
--

ALTER TABLE ONLY video_pel
    ADD CONSTRAINT pk_video PRIMARY KEY (id_video);


--
-- Name: fk_nacional_mayorista; Type: INDEX; Schema: unc_esq_peliculas; Owner: postgres
--

CREATE INDEX fk_nacional_mayorista ON nacional_pel USING btree (id_distrib_mayorista);
--
-- Name: fki_entrega_distribuidor_pel; Type: INDEX; Schema: unc_esq_peliculas; Owner: postgres
--
CREATE INDEX fki_entrega_distribuidor_pel ON entrega_pel USING btree (id_distribuidor_pel);
--
-- Name: fki_entrega_video; Type: INDEX; Schema: unc_esq_peliculas; Owner: postgres
--
CREATE INDEX fki_entrega_video ON entrega_pel USING btree (id_video);
--
-- Name: fki_re_pelicula; Type: INDEX; Schema: unc_esq_peliculas; Owner: postgres
--
CREATE INDEX fki_re_pelicula ON renglon_entrega_pel USING btree (codigo_pelicula);

--
-- Name: ciudad_pel ciudad_pel_id_pais_fkey; Type: FK CONSTRAINT; Schema: unc_esq_peliculas; Owner: postgres
--
ALTER TABLE ONLY ciudad_pel
    ADD CONSTRAINT ciudad_pel_id_pais_fkey FOREIGN KEY (id_pais) REFERENCES pais_pel
    (id_pais);
--
-- Name: departamento_pel departamento_pel_id_ciudad_fkey; Type: FK CONSTRAINT; Schema: unc_esq_peliculas; Owner: postgres
--
ALTER TABLE ONLY departamento_pel
    ADD CONSTRAINT departamento_pel_id_ciudad_fkey FOREIGN KEY (id_ciudad) REFERENCES ciudad_pel(id_ciudad);
--
-- Name: departamento_pel departamento_pel_id_distribuidor_pel_fkey; Type: FK CONSTRAINT; Schema: unc_esq_peliculas; Owner: postgres
--
ALTER TABLE ONLY departamento_pel
    ADD CONSTRAINT departamento_pel_id_distribuidor_pel_fkey FOREIGN KEY (id_distribuidor_pel) REFERENCES distribuidor_pel(id_distribuidor_pel);
--
-- Name: departamento_pel departamento_pel_jefe_departamento_fkey; Type: FK CONSTRAINT; Schema: unc_esq_peliculas; Owner: postgres
--
ALTER TABLE ONLY departamento_pel
    ADD CONSTRAINT departamento_pel_jefe_departamento_fkey FOREIGN KEY (jefe_departamento) REFERENCES empleado_pel(id_empleado);
--
-- Name: empleado_pel empleado_pel_id_distribuidor_pel_fkey; Type: FK CONSTRAINT; Schema: unc_esq_peliculas; Owner: postgres
--
ALTER TABLE ONLY empleado_pel
    ADD CONSTRAINT empleado_pel_id_distribuidor_pel_fkey FOREIGN KEY (id_distribuidor_pel, id_departamento) REFERENCES departamento_pel(id_distribuidor_pel, id_departamento);
--
-- Name: empleado_pel empleado_pel_id_jefe_fkey; Type: FK CONSTRAINT; Schema: unc_esq_peliculas; Owner: postgres
--
ALTER TABLE ONLY empleado_pel
    ADD CONSTRAINT empleado_pel_id_jefe_fkey FOREIGN KEY (id_jefe) REFERENCES empleado_pel(id_empleado);
--
-- Name: empleado_pel empleado_pel_id_tarea_fkey; Type: FK CONSTRAINT; Schema: unc_esq_peliculas; Owner: postgres
--
ALTER TABLE ONLY empleado_pel
    ADD CONSTRAINT empleado_pel_id_tarea_fkey FOREIGN KEY (id_tarea) REFERENCES tarea_pel(id_tarea);
--
-- Name: empresa_productora_pel empresa_productora_pel_id_ciudad_fkey; Type: FK CONSTRAINT; Schema: unc_esq_peliculas; Owner: postgres
--
ALTER TABLE ONLY empresa_productora_pel
    ADD CONSTRAINT empresa_productora_pel_id_ciudad_fkey FOREIGN KEY (id_ciudad) REFERENCES ciudad_pel(id_ciudad);
--
-- Name: entrega_pel fk_entrega_distribuidor_pel; Type: FK CONSTRAINT; Schema: unc_esq_peliculas; Owner: postgres
--
ALTER TABLE ONLY entrega_pel
    ADD CONSTRAINT fk_entrega_distribuidor_pel FOREIGN KEY (id_distribuidor_pel) REFERENCES distribuidor_pel(id_distribuidor_pel);
--
-- Name: entrega_pel fk_entrega_video; Type: FK CONSTRAINT; Schema: unc_esq_peliculas; Owner: postgres
--
ALTER TABLE ONLY entrega_pel
    ADD CONSTRAINT fk_entrega_video FOREIGN KEY (id_video) REFERENCES video_pel(id_video);
--
-- Name: nacional_pel fk_nacional_distribuidor_pel; Type: FK CONSTRAINT; Schema: unc_esq_peliculas; Owner: postgres
--
ALTER TABLE ONLY nacional_pel
    ADD CONSTRAINT fk_nacional_distribuidor_pel FOREIGN KEY (id_distribuidor_pel) REFERENCES distribuidor_pel(id_distribuidor_pel);
--
-- Name: nacional_pel fk_nacional_mayorista; Type: FK CONSTRAINT; Schema: unc_esq_peliculas; Owner: postgres
--
ALTER TABLE ONLY nacional_pel
    ADD CONSTRAINT fk_nacional_mayorista FOREIGN KEY (id_distrib_mayorista) REFERENCES internacional_pel(id_distribuidor_pel);
--
-- Name: renglon_entrega_pel fk_re_entrega; Type: FK CONSTRAINT; Schema: unc_esq_peliculas; Owner: postgres
--
ALTER TABLE ONLY renglon_entrega_pel
    ADD CONSTRAINT fk_re_entrega FOREIGN KEY (nro_entrega) REFERENCES entrega_pel(nro_entrega);
--
-- Name: renglon_entrega_pel fk_re_pelicula; Type: FK CONSTRAINT; Schema: unc_esq_peliculas; Owner: postgres
--
ALTER TABLE ONLY renglon_entrega_pel
    ADD CONSTRAINT fk_re_pelicula FOREIGN KEY (codigo_pelicula) REFERENCES pelicula_pel(codigo_pelicula);
--
-- Name: internacional_pel internacional_pel_id_distribuidor_pel_fkey; Type: FK CONSTRAINT; Schema: unc_esq_peliculas; Owner: postgres
--
ALTER TABLE ONLY internacional_pel
    ADD CONSTRAINT internacional_pel_id_distribuidor_pel_fkey FOREIGN KEY (id_distribuidor_pel) REFERENCES distribuidor_pel(id_distribuidor_pel) ON DELETE CASCADE;
--
-- Name: pelicula_pel pelicula_pel_codigo_productora_fkey; Type: FK CONSTRAINT; Schema: unc_esq_peliculas; Owner: postgres
--
ALTER TABLE ONLY pelicula_pel
    ADD CONSTRAINT pelicula_pel_codigo_productora_fkey FOREIGN KEY (codigo_productora) REFERENCES empresa_productora_pel(codigo_productora);