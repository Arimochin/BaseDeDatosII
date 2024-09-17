create table factura (
    tipo_factura char(1) not null,
    nro_factura int not null,
    fecha timestamp not null,
    cliente varchar(100),
    constraint pk_factura PRIMARY KEY (tipo_factura, nro_factura)
);

create table linea_factura(
    tipo_factura char(1) not null,
    nro_factura int not null,
    nro_linea int not null,
    producto varchar(80),
    precio numeric(10,2) not null default 0,
    constraint pk_linea primary key (tipo_factura, nro_factura, nro_linea)
);

alter table factura add total numeric(10,2) not null default 0;

alter table linea_factura
add constraint fk_linea foreign key (tipo_factura, nro_factura)
    references factura(tipo_factura, nro_factura)  ;

insert into factura(tipo_factura, nro_factura, fecha, cliente)
values ('B', 1, current_timestamp, 'yo');

insert into linea_factura(tipo_factura, nro_factura, nro_linea, producto, precio)
values('B', 1, 1, 'Tomates', 3000), ('B', 1, 2, 'Papa', 1500);

insert into factura(tipo_factura, nro_factura, fecha, cliente)
values ('B', 2, current_timestamp, 'yo');

insert into linea_factura(tipo_factura, nro_factura, nro_linea, producto, precio)
values('B', 2, 1, 'Tomates', 3000), ('B', 2, 2, 'Papa', 1500), ('B', 2, 3, 'x', 5500);

select *
from factura;

select *
from linea_factura;

-- agregar un campo total que vaya calculando
-- si ya tenia datos ahora esta inconsistente

update factura set
    total = (select (sum(precio) )
             from linea_factura
             where factura.nro_factura = nro_factura
             and factura.tipo_factura = tipo_factura);

--- actualizacion masiva
--- hay que dejar la base en un estado consistente,
-- porque los nuevos valores van a estar bien pero los anteriores no

create or replace function fn_act_total()
returns trigger as $$
    begin
        update factura set
            total = total + new.precio
        where factura.nro_factura = new.nro_factura
            and factura.tipo_factura = new.nro_factura;
        return new;
        -- falta controlar para un delete, restar el valor viejo?
    end;
$$ language 'plpgsql';

create or replace trigger tr_act_total
    after insert or update of precio, tipo_factura, nro_factura or delete
    on linea_factura
    for each row
    execute function fn_act_total();

-- un valor que no cambie, el new es el old
-- mas adelante que un valor solo lo pueda modificar un codigo
-- tratar delete siempre a menos que digan que no se puede borrar (y si tiene sentido no?)
-- 99% de los casos es for each row
-- no se hace for each row cuando el tiempo que tarda en procesar esas fila,
-- es mayor que el tiempo que viene una nueva actualizacion, chau BD

-- primera opcion para poner en la funcion, pero no muy eficiente, puede que levante muchas filas
        if(tg_op = 'insert' or tg_op = 'update') then
            update factura set
        total = (select (sum(precio) )
                 from linea_factura
                 where factura.nro_factura = nro_factura
                 and factura.tipo_factura = tipo_factura)
            where factura.nro_factura = new.nro_factura
                and factura.tipo_factura = new.tipo_factura;
            return new;
        end if;
            update factura set
        total = (select (sum(precio) )
                 from linea_factura
                 where factura.nro_factura = nro_factura
                 and factura.tipo_factura = tipo_factura)
            where factura.nro_factura = old.nro_factura
                and factura.tipo_factura = old.tipo_factura;
            return new;