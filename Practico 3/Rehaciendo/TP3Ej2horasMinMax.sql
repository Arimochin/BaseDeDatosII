CREATE OR REPLACE FUNCTION fn_horasMinMax()
RETURNS TRIGGER AS $$
BEGIN
    IF (tg_table_name = 'voluntario_vol') THEN
        IF ( EXISTS( SELECT 1
                     FROM voluntario_vol JOIN tarea_vol USING (id_tarea)
                     WHERE  id_tarea = new.id_tarea
                        AND new.horas_aportadas NOT BETWEEN min_horas AND max_horas ) ) THEN
            RAISE EXCEPTION 'Las horas aportadas del voluntario deben estar entre el minimo y maximo de la tarea que realiza.';
        end if;
    end if;

    IF ( tg_table_name = 'tarea_vol' ) THEN
        IF ( EXISTS( SELECT 1
                     FROM tarea_vol JOIN voluntario_vol USING (id_tarea)
                     WHERE id_tarea = new.id_tarea
                     AND horas_aportadas NOT BETWEEN new.min_horas AND new.max_horas) ) THEN
            RAISE EXCEPTION 'No puede haber voluntario con horas aportadas fuera del rango minimo y maximo de la tarea.';
        end if;
    end if;

    RETURN new;
end
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE TRIGGER tr_horasMinMax1
BEFORE INSERT OR UPDATE OF horas_aportadas, id_tarea
ON voluntario_vol
FOR EACH ROW
EXECUTE FUNCTION fn_horasMinMax();

CREATE OR REPLACE TRIGGER tr_horasMinMax2
BEFORE UPDATE OF min_horas, max_horas
ON tarea_vol
FOR EACH ROW
EXECUTE FUNCTION fn_horasMinMax();

SELECT * FROM voluntario_vol;
SELECT * FROM tarea_vol;

INSERT INTO voluntario_vol (nombre, apellido, e_mail, telefono, fecha_nacimiento, id_tarea, nro_voluntario, horas_aportadas, porcentaje, id_institucion, id_coordinador)
VALUES ('Jose', 'Martinez', 'email', '123', '9-11-1990', 'MK_REP', 220, 3000, null, null, null);

DELETE FROM voluntario_vol where nro_voluntario = 220;

INSERT INTO voluntario_vol (nombre, apellido, e_mail, telefono, fecha_nacimiento, id_tarea, nro_voluntario, horas_aportadas, porcentaje, id_institucion, id_coordinador)
VALUES ('Jose', 'Martinez', 'email', '123', '9-11-1990', 'MK_REP', 220, 5000, null, null, null);

UPDATE voluntario_vol set horas_aportadas = 3000 where nro_voluntario = 220;
UPDATE voluntario_vol set id_tarea = 'OT_NEW' where nro_voluntario = 220;

UPDATE tarea_vol set min_horas = 5500 WHERE id_tarea = 'MK_REP';
UPDATE tarea_vol set max_horas = 4000 WHERE id_tarea = 'MK_REP';

