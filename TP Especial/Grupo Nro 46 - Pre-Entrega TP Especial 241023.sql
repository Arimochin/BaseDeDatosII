---- PRE-ENTREGA TP ESPECIAL ----

-- 1.
-- a. Las personas que no están activas deben tener establecida una fecha de baja,
-- la cual se debe controlar que sea al menos 6 meses posterior a la de su alta.

-- En la tabla Persona de los atributos activo, fecha_alta, fecha_baja
-- Restriccion de tipo de tupla ya que necesito varios valores de una fila

ALTER TABLE Persona
  ADD CONSTRAINT fecha_alta_baja_6m
      CHECK ( ( activo = FALSE AND (fecha_baja is not null AND (DATE_PART('months', AGE(fecha_baja, fecha_alta)) >= 6 ) ) )
               OR activo = TRUE );


--b. El importe de un comprobante debe coincidir con el total de los importes indicados en las líneas que lo conforman (si las tuviera).

-- En las tablas Comprobante y LineaComprobante; atributos: id_comp, id_tcomp, importe;
-- Restriccion General ya que usa 2 tablas
-- Declarativa:
-- CREATE ASSERTION comprobante_coincide_linea
-- CHECK ( NOT EXISTS ( SELECT 1
-- FROM Comprobante c
-- WHERE c.importe != (SELECT sum(l.importe)
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
                     WHERE c.importe != (SELECT sum(l.importe * l.cantidad)
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
    AFTER INSERT OR UPDATE of importe OR DELETE
    ON lineacomprobante
    FOR EACH STATEMENT
    EXECUTE FUNCTION fn_tr_importe();


-- c. Las IPs asignadas a los equipos no pueden ser compartidas entre diferentes clientes.

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
   FOR EACH ROW EXECUTE FUNCTION fn_equipo_insert_update();

-----------------------------------------------------------------------------------------------------------------------------------------------
-- 2.
-- a. Al ser invocado (una vez por mes), para todos los servicios que son periódicos,
-- se deben generar e insertar los registros asociados a la/s factura/s correspondiente/s a los distintos clientes.
-- Indicar si se deben proveer parámetros adicionales para su generación y, de ser así, cuáles.

-- No pudimos lograr que el numero de las lineas de comprobante se reinicie para cada comprobante

------------------------------------- VERSION CON INSERTS MASIVOS -------------------------------------
---- SECUENCIA PARA COMPROBANTE ----
CREATE SEQUENCE comprobanteSeq
START WITH 1;

---- SECUENCIA PARA LINEA COMPROBANTE ----
CREATE SEQUENCE lineaComprobanteSeq
START WITH 1;

---- PROCEDIMIENTO ----
CREATE OR REPLACE PROCEDURE pr_serv_period_insert()
LANGUAGE plpgsql
AS $$
   BEGIN
       INSERT INTO comprobante (id_comp, id_tcomp, fecha, comentario, estado, fecha_vencimiento, id_turno, importe, id_cliente, id_lugar)
        SELECT nextval('comprobanteSeq'), 1, current_date, '', 'pendiente', current_date + 15, 1 , 0, c.id_cliente, 1
        FROM cliente c
        WHERE c.id_cliente IN (SELECT p.id_persona
                               FROM persona p
                               WHERE p.activo = true);

/*
        INSERT INTO lineacomprobante (nro_linea, id_comp, id_tcomp, descripcion, cantidad, importe, id_servicio)
        SELECT  nextval('lineaComprobanteSeq'), c.id_comp, 1, '', count(*), s.costo, s.id_servicio   /* no me gusta el asterisco */
        FROM servicio s JOIN equipo e USING(id_servicio)
                        JOIN comprobante c using(id_cliente)
        WHERE c.fecha = current_date
          AND s.periodico = true --Filtar los comprobantes del mes actual para no duplicar y que el servicio sea periodico
        GROUP BY id_servicio, id_cliente, costo, id_comp;
*/
        INSERT INTO lineacomprobante (nro_linea, id_comp, id_tcomp, descripcion, cantidad, importe, id_servicio)
        SELECT ROW_NUMBER() OVER (PARTITION BY c.id_comp ORDER BY s.id_servicio) AS nro_linea, c.id_comp, 1, '', count(*), s.costo, s.id_servicio   /* no me gusta el asterisco */
        FROM servicio s JOIN equipo e USING(id_servicio)
                        JOIN comprobante c using(id_cliente)
        WHERE c.fecha = current_date
          AND s.periodico = true --Filtar los comprobantes del mes actual para no duplicar y que el servicio sea periodico
        GROUP BY id_servicio, id_cliente, costo, id_comp;


       UPDATE comprobante c set importe = COALESCE( (SELECT SUM(importe * cantidad)
                                                     FROM lineacomprobante l
                                                     WHERE l.id_comp = c.id_comp
                                                       AND l.id_tcomp = c.id_tcomp), 0);


END; $$;

---- LLAMADA AL PROCEDIMIENTO ----
call pr_serv_period_insert();

------------------------------------- VERSION SECUENCIAL -------------------------------------
-- Esta fue la primera version que realizamos

---- SECUENCIA PARA COMPROBANTE ----
CREATE SEQUENCE id_comp START WITH 1;

---- PROCEDIMIENTO ----
CREATE OR REPLACE PROCEDURE pr_serv_period()
LANGUAGE plpgsql
AS $$
DECLARE
   var_r record;
BEGIN
   for var_r in (
       select s.id_servicio, e.id_cliente, s.costo
       from servicio s JOIN equipo e USING (id_servicio)
       where s.periodico = true AND s.activo = true
   ) loop
       IF (NOT EXISTS( SELECT 1
                       FROM comprobante c
                       WHERE var_r.id_cliente = c.id_cliente
                       AND extract(month from c.fecha) = extract(month from current_timestamp) ) ) THEN
       -- Hay que comprobar que el comprobante no sea de la misma fecha?
           INSERT INTO comprobante
           values ((select nextval('id_comp')), 1, current_timestamp, '-', null, current_timestamp + '15 days', null, '0', var_r.id_cliente, null);
       end if;

       --INSERT INTO lineacomprobante(nro_linea, id_comp, id_tcomp, descripcion, cantidad, importe, id_servicio)
       --VALUES ((select count(*) from lineacomprobante where (id_comp) ) +1, );

       INSERT INTO lineacomprobante(nro_linea, id_comp, id_tcomp, descripcion, cantidad, importe, id_servicio)
       VALUES ((select nextval('id_comp')), (SELECT DISTINCT c.id_comp FROM comprobante c WHERE id_cliente = var_r.id_cliente and extract(month from c.fecha) = extract(month from current_timestamp)),
                  1,'',1,var_r.costo,var_r.id_servicio);

       -- Nro linea autogenerado? Contador que empiece en 1 o 0 y despues vuelve a 0 para otros comprobantes?
       -- Si no compruebo la fecha habria un solo comprobante que se va llenando y no nos dejaria volver a poner en la linea 1 y asi
       -- Poniendo la fecha, cada mes haria un comprobante nuevo?

   end loop;
END; $$;

---- LLAMADA AL PROCEDIMIENTO ----
call pr_serv_period();


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
               SELECT p.id_personal, (SELECT COUNT(DISTINCT id_cliente)
                                      FROM Turno t JOIN Comprobante c using(id_turno)
                                      WHERE t.id_personal = p.id_personal
                                        AND t.desde BETWEEN fecha_inicio AND fecha_fin),
                                     (SELECT AVG(t.hasta - t.desde)
                                      FROM Turno t JOIN Comprobante c using(id_turno)
                                      WHERE t.id_personal = p.id_personal
                                        AND t.desde BETWEEN fecha_inicio AND fecha_fin),
                                     (SELECT MAX((t.hasta - t.desde))
                                      FROM Turno t JOIN Comprobante c using(id_turno)
                                      WHERE t.id_personal = p.id_personal
                                        AND t.desde BETWEEN fecha_inicio AND fecha_fin)
               FROM personal p;
   END;
$$;

---- PRUEBA ----
SELECT * FROM pr_informe_empleados('1900-10-1', current_date);

----------------------------------------------------------------------------------------------------------------------------------------------

-- 3.
-- a. Vista1, que contenga el saldo de cada uno de los clientes menores de 30 años de la ciudad ‘Napoli, que posean más de 3 servicios.

-- Como nos piden mostrar valores de una sola tabla podemos hacer la vista automaticamente actualizable
-- Necesitamos consultar otros valores pero los podemos buscar con consultas anidadas

---- VISTA 1 ----
CREATE OR REPLACE VIEW vista1 AS
   SELECT c.id_cliente, c.saldo
   FROM cliente c
   WHERE c.id_cliente in (SELECT id_persona
                          FROM persona p JOIN direccion d using(id_persona)
                                         JOIN barrio b using (id_barrio)
                                         JOIN ciudad c using (id_ciudad)
                          WHERE c.nombre = 'Napoli' and extract(year from age(fecha_nacimiento)) < 30)

     AND c.id_cliente in (SELECT e.id_cliente
                          FROM equipo e JOIN servicio s using (id_servicio)
                          GROUP BY (e.id_cliente)
                          HAVING count(id_servicio) > 3);


----
-- b. Vista2, con los datos de los clientes activos del sistema que hayan sido dados de alta en el año actual
-- y que poseen al menos un servicio activo, incluyendo el/los servicio/s activo/s que cada uno posee y su costo.

-- Como nos piden mostrar informacion de dos tablas distintas no podemos evitar que no sea automaticamente actualizable.

---- VISTA 2 ----
CREATE OR REPLACE VIEW vista2 AS
SELECT p.id_persona, p.tipo, p.tipodoc, p.nrodoc, p.nombre AS persona_nombre,
       p.apellido, p.fecha_nacimiento, p.fecha_alta, p.fecha_baja, p.CUIT, p.activo as persona_activo,
       p.mail, p.telef_area, p.telef_numero,s.id_servicio, s.nombre AS servicio_nombre,
       s.periodico,s.costo,s.intervalo,s.tipo_intervalo,s.activo as servicio_activo,s.id_cat
FROM persona p JOIN equipo e ON (id_persona = id_cliente)
               JOIN servicio s USING (id_servicio)
WHERE p.id_persona IN (SELECT c.id_cliente
                       FROM cliente c )
 AND p.activo = true
 AND extract(year from p.fecha_alta) = extract(year from current_timestamp)
 AND s.activo = true;


---- TRIGGER UPDATE ----
-- Podemos actualizar en personas sus datos
-- Podemos actualizar en servicio sus datos
----> Podemos hacer una verificacion de si existe un equipo con el cliente.
CREATE OR REPLACE FUNCTION trigger_update_vista2()
   RETURNS TRIGGER AS $$
BEGIN
   UPDATE persona
   SET tipo = NEW.tipo,
       tipodoc = NEW.tipodoc,
       nrodoc = NEW.nrodoc,
       nombre = NEW.persona_nombre,
       apellido = NEW.apellido,
       fecha_nacimiento = NEW.fecha_nacimiento,
       fecha_alta = NEW.fecha_alta,
       fecha_baja = NEW.fecha_baja,
       CUIT = NEW.CUIT,
       activo = NEW.persona_activo,
       mail = NEW.mail,
       telef_area = NEW.telef_area,
       telef_numero = NEW.telef_numero
   WHERE id_persona = NEW.id_persona;
   UPDATE servicio
   SET nombre = NEW.servicio_nombre,
       costo = NEW.costo,
       periodico = NEW.periodico,
       intervalo = NEW.intervalo,
       tipo_intervalo = NEW.tipo_intervalo,
       activo = NEW.servicio_activo,
       id_cat = NEW.id_cat
   WHERE id_servicio = NEW.id_servicio;
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

---- TRIGGER PARA VISTA2 DE UPDATE ----
CREATE TRIGGER trigger_update_vista2
INSTEAD OF UPDATE
ON vista2
FOR EACH ROW EXECUTE FUNCTION trigger_update_vista2();


---- TRIGGER INSERT ----
   --Solo tenemos id de servicio, su nombre y su costo, nos faltaria saber si es periodico y su categoria, asi que no es una opcion crear un nuevo servicio.
   --Igualmente aunque tuvieramos todos los datos del servicio, lo mas importante es que faltan datos para el equipo!, nombre del equipo y su mac. Ambiguo quizas, podriamos rellenar(alternativa)!
   --Lo que esta en la vista es porque significa que el cliente tiene un equipo que utiliza ese sevicio
CREATE OR REPLACE FUNCTION insert_vista2()
   RETURNS trigger AS $$
BEGIN
   RAISE EXCEPTION 'No se permiten operaciones de insert sobre la vista';
   RETURN null;
END;
$$ LANGUAGE plpgsql;

---- TRIGGER PARA VISTA2 DE INSERT ----
CREATE TRIGGER trigger_insert_vista2
   INSTEAD OF INSERT ON vista2
   FOR EACH ROW EXECUTE FUNCTION insert_vista2();


---- TRIGGER DELETE ----
   --Considero en solo borrar el equipo/s con la id de cliente y id de servicio de la fila borrada.
CREATE OR REPLACE FUNCTION delete_vista2()
   RETURNS trigger AS $$
BEGIN
   DELETE FROM equipo
   WHERE id_cliente = OLD.id_persona
     AND id_servicio = OLD.id_servicio;
   RETURN old;
END;
$$ LANGUAGE plpgsql;

---- TRIGGER PARA VISTA2 DE DELETE ----
CREATE OR REPLACE TRIGGER trigger_delete_vista2
   INSTEAD OF DELETE ON vista2
   FOR EACH ROW EXECUTE FUNCTION delete_vista2();

---- SECUENCIA PARA ASIGNAR VALOR A EQUIPO NUEVO ----
-- Empieza desde 1000 para que no se choque con los equipos que ya existen (los datos que pasaron)
CREATE SEQUENCE id_equipo_seq
   START WITH 1000;



---- TRIGGER INSERT ALTERNATIVA RELLENANDO DATOS DE EQUIPO ----
--En esta alternativa se crea el servicio si no existe, la persona si no existe
--Tambien surge la necesidad de agregar al select de la vista el SALDO del cliente, no sabemos si es relevante
CREATE OR REPLACE FUNCTION insert_vista2_alternativa()
   RETURNS trigger AS $$
BEGIN
   IF(NOT EXISTS(SELECT id_persona FROM persona where id_persona = new.id_persona)) THEN
       INSERT INTO persona VALUES (new.id_persona, new.tipo, new.tipodoc, new.nrodoc, new.persona_nombre, new.apellido, new.fecha_nacimiento, new.fecha_alta, new.fecha_baja, new.CUIT, new.persona_activo, new.mail, new.telef_area, new.telef_numero);
   END IF;
   --Desconocemos el saldo del cliente, por lo que no lo insertamos o insertamos 0
   IF(NOT EXISTS(SELECT id_cliente FROM cliente where id_cliente = new.id_persona)) THEN
       INSERT INTO cliente VALUES (new.id_persona,0);
   END IF;
   IF(NOT EXISTS(SELECT id_servicio FROM servicio where id_servicio = new.id_servicio)) THEN
       INSERT INTO servicio VALUES (new.id_servicio, new.servicio_nombre,new.periodico, new.costo, new.intervalo, new.tipo_intervalo, new.servicio_activo, new.id_cat);
   END IF;
   --Insertamos un equipo, el nombre es default y la mac default(no esta bueno, pero no queda de otra)
   INSERT INTO equipo VALUES (nextval('id_equipo_seq'), 'equipo nuevo', '00:00:00:00:00:00', null,null, new.id_servicio, new.id_persona,current_timestamp, null,null,null);
   RETURN new;
END;
$$ LANGUAGE plpgsql;

---- TRIGGER PARA VISTA2 DE INSERT ALTERNATIVA ----
CREATE TRIGGER trigger_insert_vista2_alternativa
   INSTEAD OF INSERT ON vista2
   FOR EACH ROW EXECUTE FUNCTION insert_vista2_alternativa();


--------PRUEBAS SOBRE LOS TRIGGERS INSTEAD OF Y SUS PROPAGACIONES--------
--La siguiente secuencia inserta en la vista 2. Se puede ver que inserta en persona, en servicio y en equipo los valores correspondientes en el caso de utilizar
--La alternativa, si no se utiliza la alternativa, no se inserta en equipo (tiraria error).
INSERT INTO vista2
VALUES (777, 'M', 'DNI', '12345678', 'Gian', 'Perez', '1980-01-01', current_timestamp, NULL, '20-12345678-9', true, '', 11, 12345678,
       777, 'Servicio1', true, 100.00, 30, 'semana', true, 1);

SELECT * FROM persona WHERE id_persona = 777;
SELECT * FROM servicio WHERE id_servicio = 777;
SELECT * FROM equipo WHERE id_cliente = 777 AND id_servicio = 777;


--La siguiente secuencia actualiza en la vista 2. Se puede ver que actualiza en persona y en servicio los valores correspondientes.
UPDATE vista2 SET persona_nombre = 'Giancarlo', servicio_nombre = 'ServicioCambiado' WHERE id_persona = 777 AND id_servicio = 777;
SELECT * FROM persona WHERE id_persona = 777;
SELECT * FROM servicio WHERE id_servicio = 777;


--La siguiente secuencia borra en la vista 2. Se puede ver que borra en equipo los valores correspondientes.
DELETE FROM vista2 WHERE id_persona = 777 AND id_servicio = 777;
SELECT * FROM equipo WHERE id_cliente = 777 AND id_servicio = 777;


----
-- c. Vista3, que contenga, por cada uno de los servicios periódicos registrados en el sistema,
-- los datos del servicio y el monto facturado mensualmente durante los últimos 5 años,
-- ordenado por servicio, año, mes y monto.

-- Como nos piden mostrar datos de diferentes tablas no podemos evitar el uso de un JOIN
-- y por lo tanto no se pueden hacer automaticamente actualizables.

CREATE OR REPLACE VIEW vista3 AS
SELECT s.*,extract(year from c.fecha), extract(month from c.fecha) ,SUM(l.importe)
FROM servicio s JOIN lineacomprobante l using(id_servicio)
                JOIN comprobante c using (id_comp,id_tcomp)
WHERE s.periodico = true and extract(year from AGE(fecha)) < 5
GROUP BY s.id_servicio, s.nombre, s.periodico, s.costo, s.intervalo, s.tipo_intervalo, s.activo, s.id_cat, extract(year from c.fecha),extract(month from c.fecha)
ORDER BY(s.id_servicio, extract(year from c.fecha), extract(month from c.fecha),SUM(l.importe));

----------------------------------------------------------------------------------------------------------------------------------------------------
---- NoSQL ----
-- 4.
-- a. Listar los tipos de intervalos y la cantidad de servicios que hay de cada tipo

/*

 db.servicio.aggregate([
    { $group:
     { _id: “$tipoIntervalo”,
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