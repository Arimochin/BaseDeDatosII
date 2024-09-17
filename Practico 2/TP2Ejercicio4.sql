CREATE TABLE voluntario AS
    SELECT * FROM unc_esq_voluntario.voluntario;

CREATE TABLE tarea AS
    SELECT * FROM unc_esq_voluntario.tarea;

CREATE TABLE institucion AS
    SELECT * FROM unc_esq_voluntario.institucion;

CREATE TABLE historico AS
    SELECT * FROM unc_esq_voluntario.historico;

ALTER TABLE voluntario
ADD CONSTRAINT PK_voluntario PRIMARY KEY (nro_voluntario);

ALTER TABLE tarea
    ADD CONSTRAINT PK_tarea PRIMARY KEY (id_tarea);

ALTER TABLE institucion
    ADD CONSTRAINT PK_institucion PRIMARY KEY (id_institucion);

ALTER TABLE historico
    ADD CONSTRAINT PK_historico PRIMARY KEY (nro_voluntario, fecha_inicio);

ALTER TABLE voluntario
ADD CONSTRAINT FK_voluntario_tarea FOREIGN KEY (id_tarea)
    REFERENCES tarea (id_tarea),
ADD CONSTRAINT FK_voluntario_institucion FOREIGN KEY (id_institucion)
    REFERENCES institucion (id_institucion),
ADD CONSTRAINT FK_voluntario_voluntario FOREIGN KEY (id_coordinador)
    REFERENCES voluntario (nro_voluntario);

ALTER TABLE historico
ADD CONSTRAINT FK_historico_voluntario FOREIGN KEY (nro_voluntario)
    REFERENCES voluntario (nro_voluntario),
ADD CONSTRAINT FK_historico_tarea FOREIGN KEY (id_tarea)
    REFERENCES tarea (id_tarea),
ADD CONSTRAINT FK_historico_institucion FOREIGN KEY (id_institucion)
    REFERENCES institucion (id_institucion);

-- a)
ALTER TABLE voluntario
ADD CONSTRAINT NoMasHorasCoordinador
    CHECK ( NOT EXISTS (SELECT 1
             FROM voluntario v JOIN voluntario c ON (v.id_coordinador = c.nro_voluntario)
             WHERE v.horas_aportadas > c.horas_aportadas ) );

--b)
CREATE ASSERTION
CHECK (NOT EXISTS (SELECT 1
                   FROM voluntario JOIN tarea USING(id_tarea)
                   WHERE horas_aportadas NOT BETWEEN (min_horas, max_horas)  ))

SELECT horas_aportadas, min_horas, max_horas
                   FROM voluntario v JOIN tarea t USING(id_tarea)
                   WHERE v.horas_aportadas BETWEEN t.min_horas AND t.max_horas;

--c)
ALTER TABLE voluntario
ADD CONSTRAINT VoluntarioTareaCoordinador
CHECK ( NOT EXISTS ( SELECT 1
                     FROM voluntario v JOIN voluntario c ON (v.id_coordinador = c.nro_voluntario)
                     WHERE v.id_tarea != c.id_tarea
));

SELECT v.nro_voluntario, v.id_tarea, v.id_coordinador, c.nro_voluntario, c.id_tarea
FROM voluntario v JOIN voluntario c ON (v.id_coordinador = c.nro_voluntario)
WHERE v.id_tarea = c.id_tarea;

--d)
ALTER TABLE historico
ADD CONSTRAINT InstitucionTresVecesAlAño
CHECK ( NOT EXISTS( SELECT 1
                    FROM historico
                    GROUP BY nro_voluntario, extract(year from fecha_inicio)
                    HAVING count(DISTINCT id_institucion) > 3 ) );

SELECT nro_voluntario, extract(year from fecha_inicio), count(DISTINCT id_institucion)
FROM historico
GROUP BY nro_voluntario, extract(year from fecha_inicio)
HAVING count(DISTINCT id_institucion) <= 3
ORDER BY nro_voluntario;

SELECT *
FROM historico
ORDER BY nro_voluntario, fecha_inicio;



