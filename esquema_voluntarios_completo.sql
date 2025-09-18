CREATE TABLE direccion_vol(
    calle character varying(40),
    codigo_postal character varying(12),
    ciudad character varying(30) NOT NULL,
    provincia character varying(25),
    id_pais character(2) NOT NULL,
    id_direccion numeric(4,0) NOT NULL
)
WITH (autovacuum_enabled='true');

CREATE TABLE tarea_vol(
    nombre_tarea character varying(40) NOT NULL,
    min_horas numeric(6,0),
    id_tarea character varying(10) NOT NULL,
    max_horas numeric(6,0)
)
WITH (autovacuum_enabled='true');


CREATE TABLE voluntario_vol
(
    nombre character varying(20),
    apellido character varying(25) NOT NULL,
    e_mail character varying(40) NOT NULL,
    telefono character varying(20),
    fecha_nacimiento date NOT NULL,
    id_tarea character varying(10) NOT NULL,
    nro_voluntario numeric(6,0) NOT NULL,
    horas_aportadas numeric(8,2),
    porcentaje numeric(2,2),
    id_institucion numeric(4,0),
    id_coordinador numeric(6,0),
    CONSTRAINT chk_hs_ap CHECK ((horas_aportadas > (0)::numeric))
)
WITH (autovacuum_enabled='true');



CREATE TABLE continente_vol(
    nombre_continente character varying(25),
    id_continente numeric NOT NULL
)
WITH (autovacuum_enabled='true');



CREATE TABLE historico_vol(
    fecha_inicio date NOT NULL,
    nro_voluntario numeric(6,0) NOT NULL,
    fecha_fin date NOT NULL,
    id_tarea character varying(10) NOT NULL,
    id_institucion numeric(4,0),
    CONSTRAINT historico_vol_check CHECK ((fecha_fin > fecha_inicio))
)
WITH (autovacuum_enabled='true');



CREATE TABLE institucion_vol(
    nombre_institucion character varying(60) NOT NULL,
    id_director numeric(6,0),
    id_direccion numeric(4,0),
    id_institucion numeric(4,0) NOT NULL
)
WITH (autovacuum_enabled='true');



CREATE TABLE pais_vol(
    nombre_pais character varying(40),
    id_continente numeric NOT NULL,
    id_pais character(2) NOT NULL
)
WITH (autovacuum_enabled='true');



INSERT INTO continente_vol
SELECT *
FROM unc_esq_voluntario.continente;


--
-- Data for Name: direccion_vol; Type: TABLE DATA; Schema: unc_esq_voluntario; Owner: postgres
--

INSERT INTO direccion_vol
select *
from unc_esq_voluntario.direccion;


--
-- Data for Name: historico_vol; Type: TABLE DATA; Schema: unc_esq_voluntario; Owner: postgres
--
insert into historico_vol
select *
from unc_esq_voluntario.historico;
--
-- Data for Name: institucion_vol; Type: TABLE DATA; Schema: unc_esq_voluntario; Owner: postgres
--

INSERT INTO institucion_vol
SELECT *
FROM unc_esq_voluntario.institucion;

--
-- Data for Name: pais_vol; Type: TABLE DATA; Schema: unc_esq_voluntario; Owner: postgres
--

INSERT INTO pais_vol
SELECT *
FROM unc_esq_voluntario.pais;

--
-- Data for Name: tarea; Type: TABLE DATA; Schema: unc_esq_voluntario; Owner: postgres
--

INSERT INTO tarea_vol
SELECT *
FROM unc_esq_voluntario.tarea;

--
-- Data for Name: voluntario; Type: TABLE DATA; Schema: unc_esq_voluntario; Owner: postgres
--

INSERT INTO voluntario_vol
SELECT *
FROM unc_esq_voluntario.voluntario;


--
-- Name: continente_vol pk_continente; Type: CONSTRAINT; Schema: unc_esq_voluntario; Owner: postgres
--

ALTER TABLE ONLY continente_vol
    ADD CONSTRAINT pk_continente PRIMARY KEY (id_continente);


--
-- Name: direccion_vol pk_direccion; Type: CONSTRAINT; Schema: unc_esq_voluntario; Owner: postgres
--

ALTER TABLE ONLY direccion_vol
    ADD CONSTRAINT pk_direccion PRIMARY KEY (id_direccion);


--
-- Name: historico_vol pk_historico; Type: CONSTRAINT; Schema: unc_esq_voluntario; Owner: postgres
--

ALTER TABLE ONLY historico_vol
    ADD CONSTRAINT pk_historico PRIMARY KEY (fecha_inicio, nro_voluntario);


--
-- Name: institucion_vol pk_institucion; Type: CONSTRAINT; Schema: unc_esq_voluntario; Owner: postgres
--

ALTER TABLE ONLY institucion_vol
    ADD CONSTRAINT pk_institucion PRIMARY KEY (id_institucion);


--
-- Name: pais_vol pk_pais; Type: CONSTRAINT; Schema: unc_esq_voluntario; Owner: postgres
--

ALTER TABLE ONLY pais_vol
    ADD CONSTRAINT pk_pais PRIMARY KEY (id_pais);


--
-- Name: tarea pk_tarea; Type: CONSTRAINT; Schema: unc_esq_voluntario; Owner: postgres
--

ALTER TABLE ONLY tarea_vol
    ADD CONSTRAINT pk_tarea PRIMARY KEY (id_tarea);


--
-- Name: voluntario pk_voluntario; Type: CONSTRAINT; Schema: unc_esq_voluntario; Owner: postgres
--

ALTER TABLE ONLY voluntario_vol
    ADD CONSTRAINT pk_voluntario PRIMARY KEY (nro_voluntario);


--
-- Name: emp_email_uk; Type: INDEX; Schema: unc_esq_voluntario; Owner: postgres
--

CREATE UNIQUE INDEX emp_email_uk ON voluntario_vol USING btree (e_mail);


--
-- Name: pais_vol fk_continente; Type: FK CONSTRAINT; Schema: unc_esq_voluntario; Owner: postgres
--

ALTER TABLE ONLY pais_vol
    ADD CONSTRAINT fk_continente FOREIGN KEY (id_continente) REFERENCES continente_vol(id_continente);


--
-- Name: voluntario fk_coordinador; Type: FK CONSTRAINT; Schema: unc_esq_voluntario; Owner: postgres
--

ALTER TABLE ONLY voluntario_vol
    ADD CONSTRAINT fk_coordinador FOREIGN KEY (id_coordinador) REFERENCES voluntario_vol (nro_voluntario);


--
-- Name: institucion_vol fk_direccion; Type: FK CONSTRAINT; Schema: unc_esq_voluntario; Owner: postgres
--

ALTER TABLE ONLY institucion_vol
    ADD CONSTRAINT fk_direccion FOREIGN KEY (id_direccion) REFERENCES direccion_vol(id_direccion);


--
-- Name: institucion_vol fk_director; Type: FK CONSTRAINT; Schema: unc_esq_voluntario; Owner: postgres
--

ALTER TABLE ONLY institucion_vol
    ADD CONSTRAINT fk_director FOREIGN KEY (id_director) REFERENCES voluntario_vol (nro_voluntario);


--
-- Name: historico_vol fk_institucion_h; Type: FK CONSTRAINT; Schema: unc_esq_voluntario; Owner: postgres
--

ALTER TABLE ONLY historico_vol
    ADD CONSTRAINT fk_institucion_h FOREIGN KEY (id_institucion) REFERENCES institucion_vol(id_institucion);


--
-- Name: voluntario fk_institucion_v; Type: FK CONSTRAINT; Schema: unc_esq_voluntario; Owner: postgres
--

ALTER TABLE ONLY voluntario_vol
    ADD CONSTRAINT fk_institucion_v FOREIGN KEY (id_institucion) REFERENCES institucion_vol(id_institucion);


--
-- Name: direccion_vol fk_pais; Type: FK CONSTRAINT; Schema: unc_esq_voluntario; Owner: postgres
--

ALTER TABLE ONLY direccion_vol
    ADD CONSTRAINT fk_pais FOREIGN KEY (id_pais) REFERENCES pais_vol(id_pais);


--
-- Name: historico_vol fk_tarea_h; Type: FK CONSTRAINT; Schema: unc_esq_voluntario; Owner: postgres
--

ALTER TABLE ONLY historico_vol
    ADD CONSTRAINT fk_tarea_h FOREIGN KEY (id_tarea) REFERENCES tarea_vol(id_tarea);


--
-- Name: voluntario fk_tarea_v; Type: FK CONSTRAINT; Schema: unc_esq_voluntario; Owner: postgres
--

ALTER TABLE ONLY voluntario_vol
    ADD CONSTRAINT fk_tarea_v FOREIGN KEY (id_tarea) REFERENCES tarea_vol(id_tarea);


--
-- Name: historico_vol fk_voluntario_h; Type: FK CONSTRAINT; Schema: unc_esq_voluntario; Owner: postgres
--

ALTER TABLE ONLY historico_vol
    ADD CONSTRAINT fk_voluntario_h FOREIGN KEY (nro_voluntario) REFERENCES voluntario_vol (nro_voluntario);