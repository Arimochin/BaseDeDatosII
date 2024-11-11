---- PRE-ENTREGA TP ESPECIAL ----

-- 1.
-- a. Las personas que no están activas deben tener establecida una fecha de baja,
-- la cual se debe controlar que sea al menos 6 meses posterior a la de su alta.

-- En la tabla Persona de los atributos activo, fecha_alta, fecha_baja
-- Restriccion de tipo de tupla ya que necesito varios valores de una fila

ALTER TABLE Persona
ADD CONSTRAINT fecha_alta_baja_6m
CHECK ( ( activo = FALSE
  AND (fecha_baja IS NOT NULL AND ( AGE(fecha_baja, fecha_alta) >= interval '6 months' ) ) )
   OR ( activo = TRUE AND fecha_baja IS NULL ) );

INSERT INTO persona values (781, 'P', 'DNI', '45295463', 'Agustin', 'Buralli', '2003-11-27', current_date, null, null, true, null, null, null);
UPDATE persona set fecha_baja = '2024-12-09', activo = false  where id_persona = 781;

--b. El importe de un comprobante debe coincidir con el total de los importes indicados en las líneas que lo conforman (si las tuviera).

-- En las tablas Comprobante y LineaComprobante; atributos: id_comp, id_tcomp, importe;
-- Restriccion General ya que usa 2 tablas

-- Declarativa:
-- CREATE ASSERTION comprobante_coincide_linea
-- CHECK ( NOT EXISTS ( SELECT 1
-- FROM Comprobante c
-- WHERE c.importe != (SELECT COALESCE( sum(l.importe * l.cantidad), 0)
--                     FROM lineacomprobante l
--                     WHERE c.id_comp = l.id_comp
--                       AND c.id_tcomp = l.id_tcomp) ) )

-- Al ser General no se puede implementar declarativamente en PostgreSQL, debemos implementarlo con Triggers.
-- En la tabla Comprobante, controlamos al realizar Insert y Update de importe, con granularidad For Each Statement
-- En la tabla LineaComprobante controlamos al realizar Insert, Update de importe y Delete, con granularidad For Each Statement

---- FUNCION ----
CREATE OR REPLACE FUNCTION fn_tr_importe()
RETURNS TRIGGER AS $$
    BEGIN
        IF ( EXISTS (SELECT 1
                     FROM comprobante c
                     WHERE c.importe != (SELECT COALESCE( sum(l.importe * l.cantidad) , 0)
                                         FROM lineacomprobante l
                                         WHERE c.id_comp = l.id_comp
                                           AND c.id_tcomp = l.id_tcomp)) ) THEN
            RAISE EXCEPTION 'El importe del comprobante debe ser igual a la suma de sus lineas';
        end if;
        RETURN NEW;
    END;
$$ LANGUAGE 'plpgsql';

---- TRIGGER EN COMPROBANTE ----
CREATE OR REPLACE TRIGGER tr_importe_comprobante
    AFTER INSERT OR UPDATE of importe
    ON comprobante
    FOR EACH STATEMENT
    EXECUTE FUNCTION fn_tr_importe();

---- TRIGGER EN LINEA COMPROBANTE ----
CREATE OR REPLACE TRIGGER tr_importe_linea_comp
   AFTER INSERT OR UPDATE of importe, id_comp, id_tcomp OR DELETE
   ON lineacomprobante
   FOR EACH STATEMENT
EXECUTE FUNCTION fn_tr_importe();


-- c. Las IPs asignadas a los equipos no pueden ser compartidas entre diferentes clientes.

-- Consideramos que los equipos no pueden tener la misma IP.
-- En la tabla Equipo; atributos: IP, id_cliente;
-- Restriccion de Tabla

-- Declarativa:
-- ALTER TABLE EQUIPO ADD CONSTRAINT ip_equipo
-- CHECK (NOT EXISTS(SELECT 1
--                  FROM EQUIPO E
--                  GROUP BY E.ip
--                  HAVING COUNT(E.id_cliente) > 1));

-- Como es de tabla, no se puede implementar declarativamente en PostgreSQL, por lo tanto debemos implementarlo con Triggers.
-- En Equipo controlamos al realizar Insert y Update de IP, con granularidad For Each Row

---- FUNCION ----
CREATE OR REPLACE FUNCTION fn_equipo_insert_update()
   RETURNS TRIGGER AS $$
BEGIN
   IF(EXISTS(SELECT id_equipo FROM Equipo WHERE id_cliente != new.id_cliente and IP = new.IP)) THEN
       RAISE EXCEPTION 'No se pueden compartir IPs entre clientes!';
   END IF;
   return new;
END;
$$ LANGUAGE 'plpgsql';

---- TRIGGER EN EQUIPO ----
CREATE OR REPLACE TRIGGER tr_equipo_insert_update
   BEFORE UPDATE OF IP, id_cliente OR INSERT
   ON Equipo
   FOR EACH ROW
   EXECUTE FUNCTION fn_equipo_insert_update();

-----------------------------------------------------------------------------------------------------------------------------------------------
-- 2.
-- a. Al ser invocado (una vez por mes), para todos los servicios que son periódicos,
-- se deben generar e insertar los registros asociados a la/s factura/s correspondiente/s a los distintos clientes.
-- Indicar si se deben proveer parámetros adicionales para su generación y, de ser así, cuáles.


---- SECUENCIA PARA COMPROBANTE ----
CREATE SEQUENCE comprobanteSeq
START WITH 1;

---- SECUENCIA PARA LINEA COMPROBANTE ----
CREATE SEQUENCE lineaComprobanteSeq
START WITH 1;

---- PROCEDIMIENTO ----
CREATE OR REPLACE PROCEDURE pr_serv_period_insert(comentario varchar(2048), estado varchar(20), dias_vencimiento int, lugar int,
                                                  descripcion_linea varchar(80))
LANGUAGE plpgsql
AS $$
   BEGIN
       INSERT INTO comprobante (id_comp, id_tcomp, fecha, comentario, estado, fecha_vencimiento, id_turno, importe, id_cliente, id_lugar)
        SELECT nextval('comprobanteSeq'), 1, current_date, comentario, estado, current_date + dias_vencimiento, null, 0, c.id_cliente, lugar
        FROM cliente c
        WHERE c.id_cliente IN (SELECT p.id_persona
                               FROM persona p
                               WHERE p.activo = true);


        INSERT INTO lineacomprobante (nro_linea, id_comp, id_tcomp, descripcion, cantidad, importe, id_servicio)
        SELECT  nextval('lineaComprobanteSeq'), c.id_comp, 1, descripcion_linea, count(*), s.costo, s.id_servicio   /* no me gusta el asterisco */
        FROM servicio s JOIN equipo e USING(id_servicio)
                        JOIN comprobante c using(id_cliente)
        WHERE c.fecha = current_date
          AND s.periodico = true --Filtar los comprobantes del mes actual para no duplicar y que el servicio sea periodico
          AND s.activo = true
        GROUP BY id_servicio, id_cliente, costo, id_comp;


       UPDATE comprobante c set importe = COALESCE( (SELECT SUM(importe * cantidad)
                                                     FROM lineacomprobante l
                                                     WHERE l.id_comp = c.id_comp
                                                       AND l.id_tcomp = c.id_tcomp), 0);


END; $$;

---- LLAMADA AL PROCEDIMIENTO ----
call pr_serv_period_insert('', 'Pendiente', 15, 1);

-- Decidimos pasar por parametro los valores comentario, estado, dias_vencimiento para sumar a la fecha actual, el id_lugar y la descripcion
-- de la linea comprobante porque no es algo que sepamos realmente que va, entonces se deja libre a que quien ejecute la funcion
-- lo pueda disponer como sugiera. Ademas pusimos el id_turno en null porque estamos armando una factura y eso
-- corresponde a otro tipo de comprobantes.

-- Funcionamiento: primero se hace un insert de todos los comprobantes, uno por cada cliente activo.
--  Luego se insertan las lineas correspondientes a los comprobantes, se hace un JOIN entre servicio con equipo por el id_servicio y luego con comprobante
--  conectando por el id_cliente, y filtrando que el comprobante sea de la fecha actual, osea la misma que los comprobantes que insertamos antes,
--  y tambien filtrando que los servicios sean periodicos. Agrupamos por servicio y cliente principalmente porque si un cliente cuenta con el mismo
--  servicio mas de una vez hay que reflejarlo en la cantidad.
--  Finalmente se hace un update en comprobante con el valor de importe, el cual es la suma del importe de las lineas por la cantidad.


------
-- b. Al ser invocado entre dos fechas cualesquiera genere un informe de los empleados (personal)
-- junto con la cantidad de clientes distintos que cada uno ha atendido en tal periodo
-- y los tiempos promedio y máximo del conjunto de turnos atendidos en el periodo.

---- FUNCION ----
CREATE OR REPLACE FUNCTION pr_informe_empleados(fecha_inicio TIMESTAMP, fecha_fin TIMESTAMP )
   RETURNS TABLE(
                    id_personal integer,
                    cant_clientes bigint,
                    tiempo_promedio interval,
                    tiempo_max interval
                )
   LANGUAGE 'plpgsql' as $$
BEGIN
   return query
       SELECT t.id_personal, COUNT(DISTINCT id_cliente), AVG(t.hasta - t.desde), MAX(t.hasta - t.desde)
       FROM turno t JOIN comprobante c USING(id_turno)
       WHERE t.desde >= fecha_inicio AND t.hasta <= fecha_fin
       GROUP BY t.id_personal;
END;
$$;


---- PRUEBA ----
SELECT * FROM pr_informe_empleados('1900-10-1', current_date);

-- Funcionamiento: la funcion retorna un tabla que en cada columna lleva la informacion solicitada del informe. Se hace un JOIN
--  entre turno y comprobante para buscar al personal que ha atendido a alguien, luego se filtra en el periodo que se solicita
--  y agrupamos por id_personal para contar cada cliente.

----------------------------------------------------------------------------------------------------------------------------------------------

-- 3.
-- a. Vista1, que contenga el saldo de cada uno de los clientes menores de 30 años de la ciudad ‘Napoli, que posean más de 3 servicios.

-- Como nos piden mostrar valores de una sola tabla podemos hacer la vista automaticamente actualizable
-- Necesitamos consultar otros valores pero los podemos buscar con consultas anidadas

---- VISTA 1 ----
CREATE OR REPLACE VIEW vista1 AS
SELECT c.id_cliente, c.saldo
FROM cliente c
WHERE c.id_cliente IN (SELECT id_persona
                       FROM persona p JOIN direccion d using(id_persona)
                                      JOIN barrio b using (id_barrio)
                                      JOIN ciudad c using (id_ciudad)
                       WHERE c.nombre = 'Napoli'
                        AND extract(year from age(fecha_nacimiento)) < 30 )
 AND c.id_cliente IN (SELECT e.id_cliente
                      FROM equipo e
                      GROUP BY (e.id_cliente)
                      HAVING count(id_servicio) > 3);

------------------- Planteamos una sentencia que tenga distinto comportamiento si la vista tiene o no WCO -------------------

-- Creamos una persona menor de 30 años
INSERT INTO persona (id_persona, tipo, tipodoc, nrodoc, nombre, apellido, fecha_nacimiento, fecha_alta, fecha_baja, cuit, activo, mail, telef_area, telef_numero)
VALUES (801,'Cliente','DNI',12345678,'Juan','Perez','1999-01-01','2010-01-01',NULL,NULL,true,'',null,null);
-- Creamos la ciudad Napoli y generamos una direccion
INSERT INTO ciudad (id_ciudad,nombre) VALUES (801,'New York');
INSERT INTO barrio (id_barrio,nombre,id_ciudad) VALUES (801,'Barrio1',801);
-- Creamos una direccion para la persona creada
INSERT INTO direccion (id_direccion,calle,numero,id_barrio,id_persona) VALUES (801,'Calle1',801,801,801);


-- Si la vista no tiene WCO podemos insertar en ella una tupla que no se mostraria en ella debido a sus condiciones
-- (que tenga menos de 30 años y mas de 3 servicios, que viva en Napoli).
INSERT INTO vista1 (id_cliente,saldo) VALUES (801,1000);
-- Si miramos en la vista no se muestra la tupla insertada
SELECT * FROM vista1 WHERE id_cliente = 801;
-- Si miramos en la tabla base si se inserto la tupla
SELECT * FROM cliente WHERE id_cliente = 801;
-- Ahora si creamos la vista con WCO y veremos que la tupla no se insertara en ningun lado ya que WCO previene la migracion tuplas
-- que no cumplen con las condiciones de la vista

CREATE OR REPLACE VIEW vista1_WCO AS
SELECT c.id_cliente, c.saldo
FROM cliente c
WHERE c.id_cliente in (SELECT id_persona FROM persona p JOIN direccion d using(id_persona)
                                                       JOIN barrio b using (id_barrio)
                                                       JOIN ciudad c using (id_ciudad)
                      WHERE c.nombre = 'Napoli' and extract(year from age(fecha_nacimiento)) < 30)
 and c.id_cliente IN (SELECT e.id_cliente FROM equipo e GROUP BY (e.id_cliente) HAVING count(id_servicio) > 3)
WITH CHECK OPTION;


-- Borramos la tupla insertada antes
DELETE FROM cliente WHERE id_cliente = 801;
-- Insertamos la tupla en la vista con WCO
INSERT INTO vista1_WCO (id_cliente,saldo) VALUES (801,1000);
-- Y nos tira error ya que la tupla no cumple con las condiciones de la vista




----
-- b. Vista2, con los datos de los clientes activos del sistema que hayan sido dados de alta en el año actual
-- y que poseen al menos un servicio activo, incluyendo el/los servicio/s activo/s que cada uno posee y su costo.

-- Como nos piden mostrar informacion de dos tablas distintas no podemos evitar que no sea automaticamente actualizable.

---- VISTA 2 ----
CREATE OR REPLACE VIEW vista2 AS
SELECT p.id_persona, p.tipo, p.tipodoc, p.nrodoc, p.nombre, p.apellido, p.fecha_nacimiento, p.fecha_alta, p.fecha_baja, p.CUIT,
       p.activo, p.mail, p.telef_area, p.telef_numero,s.id_servicio, s.nombre AS servicio_nombre, s.costo
FROM persona p JOIN equipo e ON (id_persona = id_cliente)
               JOIN servicio s USING (id_servicio)
WHERE p.id_persona IN (SELECT c.id_cliente
                       FROM cliente c )
  AND p.activo = true
  AND extract(year from p.fecha_alta) = extract(year from current_timestamp)
  AND s.activo = true;


-- TRIGGER INSERT
-- No armamos un trigger insert ya que no nos parece correcto. A la vista le faltan datos para insertar en equipo. Como por ejemplo
-- su mac, IP, nombre, datos que no pueden faltar.
-- Esta falta de datos genera ambiguedad en la insercion de datos en la tabla equipo, por lo que no se puede insertar en la vista2.


-- TRIGGER UPDATE
-- En el caso del update tambien no consideramos permitirlo al igual que el insert. El update sobre la vista2 genera
-- inconvenientes cuando cambiamos alguna de las pks de la vista, es decir, id_persona o id_servicio.
-- id_persona es utilizada como fk en equipo y cliente, e id_servicio es utilizada como fk en equipo. En el script de creacion
-- de la base de datos no se contemplan las actualizaciones de las fk, y por defecto no se actualizan (esta en ON UPDATE NO ACTION por default),
-- lo que imposibilita la actualizacion de las claves foraneas en las tablas equipo y cliente, por lo que no se puede actualizar la vista2.
-- Podriamos tranquilamente permitir la actualización de los campos que no son pk, pero no esta bien dejar actualizar solo una parte de la vista.
-- Una solucion a este problema seria alterar las tablas del esquema que dependan de las claves de la vista y agregarles que ON UPDATE CASCADE, pero
-- no quisimos hacerlo ya que esto no forma parte de la consigna y no queremos modificar el script de creacion original.


-- TRIGGER DELETE
-- Consideramos en solo borrar el equipo/s con la id de cliente y id de servicio de la fila borrada. No nos parece bien borrar
-- una fila en persona ni menos en servicio, ya que el servicio puede estar siendo utilizado por otro cliente. Y la persona puede tener otros equipos.
-- Lo que nos parece mas adecuado es simplemente borrar la conexion que produce que ese servicio se muestre en la vista junto con el cliente, osea el equipo.

CREATE OR REPLACE FUNCTION delete_vista2()
   RETURNS trigger AS $$
BEGIN
   DELETE FROM equipo
   WHERE id_cliente = OLD.id_persona
     AND id_servicio = OLD.id_servicio;
   RETURN old;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_delete_vista2
   INSTEAD OF DELETE ON vista2
   FOR EACH ROW EXECUTE FUNCTION delete_vista2();


-------- PRUEBAS SOBRE LOS TRIGGERS INSTEAD OF Y SUS PROPAGACIONES --------
-- La siguiente secuencia inserta en la vista 2. Se puede ver que NO inserta en persona, en servicio y en equipo ya que
-- no se puede insertar en la vista2 debido a que no es automaticamente actualizable y las consideraciones tomadas anteriormente.

INSERT INTO vista2
VALUES (777, 'M', 'DNI', '12345678', 'Gian', 'Perez', '1980-01-01', current_timestamp, NULL, '20-12345678-9', true, '', 11, 12345678,
       777,  'Servicio777', 100.00);

SELECT * FROM persona WHERE id_persona = 777;
SELECT * FROM servicio WHERE id_servicio = 777;
SELECT * FROM equipo WHERE id_cliente = 777 AND id_servicio = 777;


-- Hagamos ahora algun ejemplo que aparezca en la vista2
INSERT INTO persona VALUES (777, 'M', 'DNI', '12345678', 'Gian', 'Perez', '1980-01-01', current_timestamp, NULL, '20-12345678-9', true, '', 11);
INSERT INTO cliente VALUES (777,1000);
INSERT INTO servicio VALUES (777,'Servicio777',true,100.00,30,'semana',true,1);
INSERT INTO servicio VALUES (778,'Servicio778',true,200.00,30,'semana',true,1);
INSERT INTO equipo VALUES (777,'equipo777','mac1','ip1','nombre1',777,777,current_timestamp);
INSERT INTO equipo VALUES (778,'equipo778','mac2','ip2','nombre2',778,777,current_timestamp);


-- Veamos si se muestra en la vista2
SELECT * FROM vista2 WHERE id_persona = 777;
-- Como vemos se muestra en la vista2 dos entradas correspondientes para la persona con id 777 ya que posee dos equipos activos con servicios activos.


-- Probemos ahora con un update sobre la vista cambiando el nombre de la persona y el nombre del servicio, y sus ids.
-- La siguiente secuencia actualiza en la vista 2. Se puede ver que NO actualiza en persona y en servicio los valores
--  correspondientes debido a que no es actualizable y las consideraciones anteriores.

UPDATE vista2 SET id_servicio=998,id_persona = 998 ,nombre = 'Giancarlo', servicio_nombre = 'ServicioCambiado' WHERE id_persona = 777 AND id_servicio = 777;
SELECT * FROM persona WHERE id_persona = 777;
SELECT * FROM servicio WHERE id_servicio = 777;


-- La siguiente secuencia borra en la vista 2. Se puede ver que borra en equipo los valores correspondientes.
-- Esta accion si es posible y podemos ver como se borra el equipo y consecuentemente la entrada en la vista2.
DELETE FROM vista2 WHERE id_persona = 777;
SELECT * FROM equipo WHERE id_cliente = 777;
SELECT * FROM vista2 WHERE id_persona = 777;



----
-- c. Vista3, que contenga, por cada uno de los servicios periódicos registrados en el sistema,
-- los datos del servicio y el monto facturado mensualmente durante los últimos 5 años,
-- ordenado por servicio, año, mes y monto.

-- Como nos piden mostrar datos de diferentes tablas no podemos evitar el uso de un JOIN
-- y por lo tanto no se pueden hacer automaticamente actualizables.

CREATE OR REPLACE VIEW vista3 AS
SELECT s.*,extract(year from c.fecha) AS anio, extract(month from c.fecha) as mes ,SUM(l.importe * l.cantidad) as monto_facturado
FROM servicio s JOIN lineacomprobante l using(id_servicio)
                JOIN comprobante c using (id_comp,id_tcomp)
WHERE s.periodico = true
  AND extract(year from AGE(fecha)) < 5 and id_tcomp = 1 --Verificar que sea una factura lo que contamos
GROUP BY s.id_servicio, s.nombre, s.periodico, s.costo, s.intervalo, s.tipo_intervalo, s.activo, s.id_cat,
         extract(year from c.fecha), extract(month from c.fecha)
ORDER BY (s.id_servicio, extract(year from c.fecha), extract(month from c.fecha), SUM(l.importe* l.cantidad));


----------------------------------------------------------------------------------------------------------------------------------------------------
---- NoSQL ----
-- 4.
-- a. Listar los tipos de intervalos y la cantidad de servicios que hay de cada tipo

/*

 db.servicio.aggregate([
    { $group:
     { _id: "$tipoIntervalo",
 	   servicios: { $count: {} } }
      } ]);

*/

-- b. Para cada uno de los clientes que haya tenido un total de facturación superior a 250,
-- listar el identificador del cliente, el total de facturación y la cantidad de comprobantes,
-- ordenando descendentemente por el total.

/*

db.comprobante.aggregate( [
  {
    $group:
      { _id: "$idCliente",
        totalFacturacion: { $sum: "$importe" },
        cantidadComprobantes: { $count: {} } }
  },
  {
    $match:
      { totalFacturacion: { $gt: 250 } }
  },
  {
    $sort: { totalFacturacion: -1 }
  }
] );

 */