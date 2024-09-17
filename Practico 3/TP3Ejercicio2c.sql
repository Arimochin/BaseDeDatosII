-- Todos los voluntarios deben realizar la misma tarea que su coordinador

CREATE OR REPLACE FUNCTION fn_tr_volTareaCoordinador()
RETURNS TRIGGER AS $$
    BEGIN
        IF ( EXISTS ( SELECT 1
                      FROM voluntario v JOIN voluntario c ON (v.id_coordinador = c.nro_voluntario)
                      ) ) THEN

        END IF;
    END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER tr_volTareaCoordinador
    BEFORE INSERT OR UPDATE OF id_tarea, id_coordinador
    ON voluntario
    FOR EACH ROW
    EXECUTE FUNCTION fn_tr_volTareaCoordinador();