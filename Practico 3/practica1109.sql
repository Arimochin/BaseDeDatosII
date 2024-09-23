create or replace function fn_tope_productos()
returns trigger as $$
    begin
        if ( ( select count(*) from provee
                               where nro_prov = new.nro_prov
                               and cod_suc = new.cod_suc) >= 3 ) then
            -- >= 3 contemplar lo que hay en la tabla porque es before
            raise exception 'La cantidad de productos excede el limite';
        end if;
        return new;
        -- todo trigger retorna algo
    end;
$$ language 'plpgsql';

create trigger chk_tope_productos
    before insert or update of cod_suc, nro_prov
    ON provee
    FOR EACH ROW
    EXECUTE FUNCTION fn_tope_productos();

-----------------------------------------------------------------------------------------------------
-- sobre el ejercicio 7
-- ej2 tp2 articulo contiene palabra
-- procedimiento para juntar informacion
-- triggers para mantener la base consistente

create table textosporautor (
    autor varchar(50) not null,
    cant_textos integer not null,
    fecha_ultima_public date
);

create procedure actualizar_textos_autor()
language 'plpgsql' as $$
    begin
        -- delete from textosporautor; -- borrar informacion previa de la tabla
        insert into textosporautor /*(podria poner los parametros aca, autor, cant_textos, fecha)*/
            select autor, count(id_articulo), max (fecha_pub)
            from articulo
            group by autor;
    end;
$$

select * from textosporautor;
select * from articulo;

call actualizar_textos_autor(); -- llamar procedimiento

----------------------------------------
--contar cantidad de filas de un insert, update o delete
-- caso sin delete
create table aux_contador(
    col char(1)
);

create function fn_fila()
returns trigger as $$
    begin
        insert into aux_contador(col) values ('z');
        return new;
    end;
$$ language 'plpgsql';

create trigger tr_fila
    after insert or update
    on voluntario
    for each row
    execute function fn_fila();

select count(*) from voluntario;
select * from aux_contador;
update voluntario set horas_aportadas = horas_aportadas + 1;

--trigger a nivel statement qu me cuente la cant de filas

create function fn_statement()
returns trigger as $$
    begin
        insert into his_voluntario (fecha, usuario, operacion, cant_registros)
        values (current_timestamp, current_user, tg_op, (select count(*) from aux_contador));
        delete from aux_contador;
        return null;
    end;
$$ language 'plpgsql';

create trigger tr_statement
    AFTER INSERT OR UPDATE -- faltaria por delete
    ON voluntario
    FOR STATEMENT -- si no aclaro nada es por statement
    execute function fn_statement();

delete from aux_contador;

select *
from aux_contador;

select *
from his_voluntario;

--dependa la operacion retorno new o old, para delete
-- problema que podria llegar a tener: si lo hacen multiples usuarios

-- en un trigger before los datos no estan en la tabla

-- orden preestablecido para

-- primer trigger que se ejecuta: before statement
-- segundo: before row
-- after row
-- after statement