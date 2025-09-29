-- Ejercicio 6
-- Para las siguientes vistas de ensamble sobre el esquema de Peliculas (unc_esq_peliculas):
-- CREATE VIEW ciudad_kp_2 AS
-- SELECT id_ciudad, nombre_ciudad, c.id_pais, nombre_pais
-- FROM ciudad c NATURAL JOIN pais p;
--
-- CREATE VIEW entregas_kp_3 AS
-- SELECT nro_entrega, re.codigo_pelicula, cantidad, titulo
-- FROM renglon_entrega re JOIN pelicula p using (codigo_pelicula);
--
-- Indique en cada caso cuál es la clave preservada en la vista, de qué tabla proviene y qué atributos de la vista se pueden actualizar de acuerdo al estándar SQL
-- Escriba la implementación completa de los triggers INSTEAD OF que considere adecuados para permitir actualizaciones en cada una de las vistas en Postgresql. Justifique.
-- Provea sentencias de actualización sobre cada vista e indique su propagación sobre las tablas base.

CREATE VIEW ciudad_kp_2 AS
SELECT id_ciudad, nombre_ciudad, c.id_pais, nombre_pais
FROM ciudad_pel c NATURAL JOIN pais_pel p;

CREATE VIEW entregas_kp_3 AS
SELECT nro_entrega, re.codigo_pelicula, cantidad, titulo
FROM renglon_entrega_pel re JOIN pelicula_pel p using (codigo_pelicula);

-- ciudad_kp_2
-- la clave preservada es id_ciudad de la tabla ciudad.
-- los atributos actualizables son

CREATE OR REPLACE FUNCTION fn_ins_ciudad_kp_2()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS ( SELECT 1 FROM ciudad_pel WHERE id_ciudad = new.id_ciudad ) AND
       EXISTS (SELECT 1 FROM pais_pel WHERE id_pais = new.id_pais) THEN

        
    end if;
end;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER tr_ins_ciudad_kp_2
INSTEAD OF INSERT ON ciudad_kp_2
FOR EACH ROW
EXECUTE FUNCTION fn_ins_ciudad_kp_2();


-- entregas_kp_3
-- claves preservadas nro_entrega y codigo_pelicula de renglon_entrega, codigo_pelicula es fk y pk de pelicula.
