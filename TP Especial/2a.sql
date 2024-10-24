-- 2.a
-- a. Al ser invocado (una vez por mes), para todos los servicios que son periódicos,
-- se deben generar e insertar los registros asociados a la/s factura/s correspondiente/s a los distintos clientes.
-- Indicar si se deben proveer parámetros adicionales para su generación y, de ser así, cuáles.

CREATE SEQUENCE id_comp START WITH 1;


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

   -- INSERT INTO comprobante
   -- values ((select nextval('id_comp')), 1, current_timestamp, '-', null, current_timestamp + '15 days', null, '0', (select distinct c.id_cliente
   --                                                                                                                     from cliente c), null);

END; $$;

call pr_serv_period();

SELECT * FROM comprobante;
SELECT * FROM lineacomprobante;
DELETE FROM comprobante;
DELETE FROM lineacomprobante;

