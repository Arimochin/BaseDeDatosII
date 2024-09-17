CREATE OR REPLACE FUNCTION fn_tr_noMasHorasCoordinador()
RETURNS TRIGGER AS $$
    BEGIN
        IF ( EXISTS(SELECT 1
                    FROM voluntario v JOIN voluntario c ON (v.id_coordinador = c.nro_voluntario)
                    WHERE (/*v.nro_voluntario = new.nro_voluntario AND*/c.nro_voluntario = new.id_coordinador)
                    AND new.horas_aportadas > c.horas_aportadas OR new.horas_aportadas < v.horas_aportadas
                    )  ) THEN
            RAISE EXCEPTION 'Las horas aportadas del voluntario no deben ser mayor a las horas aportadas de su coordinador';
        END IF;
        RETURN NEW;
    END
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER tr_noMasHorasCoordinador
    BEFORE INSERT OR UPDATE of horas_aportadas, id_coordinador
    ON voluntario
    FOR EACH ROW
    EXECUTE FUNCTION fn_tr_noMasHorasCoordinador();

-- casos:
-- si inserto un voluntario con sus datos, que las horas aportadas sean mayor que las de su coordinador
-- si cambio las horas aportadas, que sean mayor a las de su coordinador
-- si cambio el id_coordinador, que las horas aportadas sean mayor a las del nuevo coordinador
-- si cambio las horas aportadas, si este coordina a alguien,
-- que las horas sean menor que la de alguno de los voluntarios que coordina

--insertar voluntario
INSERT INTO voluntario (nombre, apellido, e_mail, telefono, fecha_nacimiento, id_tarea, nro_voluntario, horas_aportadas, porcentaje, id_institucion, id_coordinador)
values ('Juanito', 'Perez', 'jperez@gmail.com', 2284, '10/12/2000', 'AD_PRES', 300, 30000, null, 90, 100);

DELETE FROM voluntario where nro_voluntario = 300;

--update voluntario
INSERT INTO voluntario (nombre, apellido, e_mail, telefono, fecha_nacimiento, id_tarea, nro_voluntario, horas_aportadas, porcentaje, id_institucion, id_coordinador)
values ('Juanito', 'Perez', 'jperez@gmail.com', 2284, '10/12/2000', 'AD_PRES', 300, 20000, null, 90, 320);

UPDATE voluntario set horas_aportadas = 30000 where nro_voluntario = 300;

UPDATE voluntario set id_coordinador = 120 where nro_voluntario = 300;

INSERT INTO voluntario (nombre, apellido, e_mail, telefono, fecha_nacimiento, id_tarea, nro_voluntario, horas_aportadas, porcentaje, id_institucion, id_coordinador)
values ('Jose', 'Martinez', 'jmar@gmail.com', 2494, '10/11/1990', 'AD_PRES', 320, 24000, null, 90, null);

UPDATE voluntario set horas_aportadas = 24000 where nro_voluntario = 320;
UPDATE voluntario set horas_aportadas = 19000 where nro_voluntario = 320;

--DELETE FROM voluntario where nro_voluntario = 320;

SELECT v.nro_voluntario, v.horas_aportadas, v.id_coordinador
FROM voluntario v
ORDER BY nro_voluntario;

SELECT 1
                    FROM voluntario v JOIN voluntario c ON (v.id_coordinador = c.nro_voluntario)
                    WHERE v.nro_voluntario = v.nro_voluntario
                    AND v.horas_aportadas > c.horas_aportadas