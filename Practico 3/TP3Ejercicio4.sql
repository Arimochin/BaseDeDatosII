 ---------- TP3 EJERCICIO 4 -----------
-- En el esquema de Películas, considere que se quiere mantener un registro de quién y cuándo realizó actualizaciones sobre las entregas de películas.
-- Cree una tabla HIS_ENTREGA que tenga por lo menos las siguientes columnas: nro_registro, fecha, operación, cant_reg_afectados, usuario.

CREATE TABLE his_entrega (
    nro_registro       integer ,
    fecha              timestamp,
    operacion          varchar(30),
    cant_reg_afectados integer,
    usuario            varchar(80)
);

-- Provea el/los trigger/s necesario/s para mantener actualizada en forma automática la tabla HIS_ENTREGA
-- cuando se realizan actualizaciones (insert, update o delete) en la tabla ENTREGA o RENGLON_ ENTREGA
CREATE TABLE aux_contador(
    col char(1)
);

CREATE OR REPLACE FUNCTION fn_tr_fila()
RETURNS TRIGGER AS $$
    BEGIN
        INSERT INTO aux_contador(col) values ('z');
        RETURN new;
    end;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER tr_fila
     AFTER INSERT OR UPDATE OR DELETE
     ON renglon_entrega
     FOR EACH ROW
     EXECUTE FUNCTION fn_tr_fila();

CREATE OR REPLACE TRIGGER tr_fila_entrega
     AFTER INSERT OR UPDATE OR DELETE
     ON entrega
     FOR EACH ROW
     EXECUTE FUNCTION fn_tr_fila();


CREATE OR REPLACE FUNCTION fn_tr_his_entrega()
RETURNS TRIGGER AS $$
    BEGIN
        --IF (tg_op = 'update') THEN
            insert into his_entrega(nro_registro, fecha, operacion, cant_reg_afectados, usuario)
            values(new.nro_entrega, current_timestamp, tg_op, (select count(*) from aux_contador), current_user);
            delete from aux_contador;
            return null;
        --end if;
    END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER tr_his_entrega
     BEFORE INSERT OR DELETE OR UPDATE
     ON entrega
     FOR STATEMENT
     EXECUTE FUNCTION fn_tr_his_entrega();

CREATE OR REPLACE TRIGGER tr_his_entrega_renglon
     BEFORE INSERT OR DELETE OR UPDATE
     ON renglon_entrega
     FOR STATEMENT
     EXECUTE FUNCTION fn_tr_his_entrega();

SELECT * FROM entrega
ORDER BY nro_entrega DESC
LIMIT 5;

SELECT * FROM renglon_entrega
ORDER BY nro_entrega DESC
LIMIT 5;

UPDATE renglon_entrega set cantidad = 10 where nro_entrega = 8049 and codigo_pelicula = 21885;

SELECT * FROM his_entrega;

-- Determine el resultado en las tablas si se ejecuta la operación:
-- DELETE FROM ENTREGA  WHERE id_video = 3582 ;
-- según el o los triggers definidos sean FOR EACH ROW o FOR EACH STATEMENT, evalúe la diferencia a partir de ambos tipos de granularidad.

