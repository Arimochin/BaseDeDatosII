create table voluntario as
    select * from unc_esq_voluntario.voluntario

select current_timestamp;

create table auditoria(
    id serial not null,
    usuario varchar(80),
    fecha timestamp,
    val_viejo varchar(80),
    val_nuevo varchar(80),
    constraint pk_auditoria primary key (id)
);

create function fn_tr_auditoria() returns trigger as $$
begin
    insert into auditoria(usuario, fecha, val_viejo, val_nuevo) values
            (current_user, current_timestamp, old.nombre, new.nombre);
    return new;

end;
    $$ language 'plpgsql';

create trigger tr_auditoria
    after insert or update
    on voluntario
    for each row
    execute function fn_tr_auditoria();

select count(*) from voluntario;

update voluntario set
    nombre =  nombre || ' 1';

select * from auditoria;

-- con each row, el valor nuevo y viejo son los valores viejos de cada fila
-- si lo hago statement, se activa una sola vez, por lo tanto no sabria cual es
--      el valor new y old de cada fila.

-- entonces mejor each row cuando necesito los valores nuevo/viejo de cada fila