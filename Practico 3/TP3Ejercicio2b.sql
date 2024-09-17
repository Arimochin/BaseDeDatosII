-- Las horas aportadas por un voluntario deben estar dentro de los valores máximos
-- y mínimos consignados en la tarea que realiza.

CREATE OR REPLACE FUNCTION fn_tr_horas_aportadas()
RETURNS TRIGGER AS $$
    BEGIN
        IF ( EXISTS (SELECT 1
                     FROM voluntario v JOIN tarea t USING (id_tarea)
                     WHERE /*v.nro_voluntario = new.nro_voluntario
                        AND*/ t.id_tarea = new.id_tarea
                        AND new.horas_aportadas NOT BETWEEN t.min_horas AND t.max_horas) ) THEN
            RAISE EXCEPTION 'Las horas aportadas de los voluntarios deben estar entre el min y max de sus tareas';
        END IF;
        RETURN NEW;
    END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER tr_horas_aportadas
    BEFORE INSERT OR UPDATE of horas_aportadas, id_tarea
    ON voluntario
    FOR EACH ROW
    EXECUTE FUNCTION fn_tr_horas_aportadas();

SELECT * FROM voluntario WHERE nro_voluntario = 300;
SELECT * FROM tarea WHERE id_tarea = 'AD_PRES';
UPDATE voluntario set horas_aportadas = 19000 where nro_voluntario = 300;

SELECT * FROM tarea;
UPDATE voluntario set id_tarea = 'AD_ASST' where nro_voluntario = 300;