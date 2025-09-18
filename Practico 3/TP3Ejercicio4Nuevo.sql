CREATE TABLE his_entrega (
    nro_registro serial,
    fecha date,
    operacion varchar,
    cant_reg_afectados int,
    usuario varchar
);

CREATE TABLE aux (
    id int
);

CREATE OR REPLACE FUNCTION fn_aux()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO aux (id) VALUES (1);
    IF (tg_op = 'DELETE') THEN
       RETURN old;
    end if;
    RETURN NEW;
end;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER tr_aux_entrega
BEFORE INSERT OR UPDATE OR DELETE
ON entrega_pel
FOR EACH ROW
EXECUTE FUNCTION fn_aux();

CREATE OR REPLACE TRIGGER tr_aux_renglon
BEFORE INSERT OR UPDATE OR DELETE
ON renglon_entrega_pel
FOR EACH ROW
EXECUTE FUNCTION fn_aux();

/*
CREATE OR REPLACE FUNCTION fn_delete_aux()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM aux;
   -- IF (tg_op = 'Delete') THEN
    --    RETURN old;
    --end if;
    --RETURN new;
    return null;
end;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE TRIGGER tr_delete_aux
BEFORE INSERT OR UPDATE OR DELETE
ON entrega_pel
FOR EACH STATEMENT
EXECUTE FUNCTION fn_delete_aux();
*/



CREATE OR REPLACE FUNCTION fn_entregas()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO his_entrega (fecha, operacion, cant_reg_afectados, usuario)
    VALUES (current_date, tg_op, (SELECT count(*) FROM aux), current_user);
    delete from aux;
    return null;
end;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE TRIGGER tr_iud_entregas
AFTER INSERT OR UPDATE OR DELETE
ON entrega_pel
FOR EACH STATEMENT
EXECUTE FUNCTION fn_entregas();

CREATE OR REPLACE TRIGGER tr_iud_renglon
AFTER INSERT OR UPDATE OR DELETE
ON renglon_entrega_pel
FOR EACH STATEMENT
EXECUTE FUNCTION fn_entregas();







SELECT *
FROM his_entrega;

INSERT INTO unc_213.entrega_pel (nro_entrega, fecha_entrega, id_video, id_distribuidor_pel) VALUES (8051, '2024-03-04', 1, 2);
DELETE FROM entrega_pel where nro_entrega = 8051;

SELECT * FROM renglon_entrega_pel WHERE nro_entrega = 8051;

SELECT * FROM entrega_pel WHERE nro_entrega = 8051;
SELECT * FROM renglon_entrega_pel WHERE nro_entrega = 8051;