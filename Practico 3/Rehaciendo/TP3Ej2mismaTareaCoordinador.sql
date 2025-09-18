CREATE OR REPLACE FUNCTION fn_mismaTareaCoordinador()
RETURNS TRIGGER AS $$
BEGIN
    IF ( EXISTS( SELECT 1
                 FROM voluntario_vol v JOIN voluntario_vol c ON v.id_coordinador = c.nro_voluntario
                 WHERE new.id_coordinador = v.id_coordinador
                 ) ) THEN

    end if;
end;
$$ LANGUAGE 'plpgsql';



CREATE OR REPLACE FUNCTION fn_mismaTareaCoordinadorCaso1()
RETURNS TRIGGER AS $$
BEGIN
    IF ( new.id_coordinador IS NOT NULL ) THEN
        IF ((SELECT id_tarea
            FROM voluntario_vol c
            WHERE new.id_coordinador = c.nro_voluntario) != new.id_tarea ) THEN
            RAISE EXCEPTION 'Tarea de voluntario diferente a su coordinador';
        end if;
    end if;
    RETURN new;
end;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION fn_mismaTareaCoordinadorCaso2()
RETURNS TRIGGER AS $$
BEGIN
    IF ( EXISTS( SELECT 1
                 FROM voluntario_vol v
                 WHERE new.nro_voluntario = v.id_coordinador
                    AND new.id_tarea != v.id_tarea) ) THEN
        RAISE EXCEPTION 'Tarea de coordinador diferente a la de voluntario que coordina';
    end if;
    RETURN new;
end;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER tr_mismaTareaCoordinador
BEFORE INSERT OR UPDATE OF id_coordinador, id_tarea
ON voluntario_vol
FOR EACH ROW
EXECUTE FUNCTION fn_mismaTareaCoordinadorCaso1();

CREATE OR REPLACE TRIGGER tr_mismaTareaCoordinador
BEFORE UPDATE OF id_tarea
ON voluntario_vol
FOR EACH ROW
EXECUTE FUNCTION fn_mismaTareaCoordinadorCaso2();