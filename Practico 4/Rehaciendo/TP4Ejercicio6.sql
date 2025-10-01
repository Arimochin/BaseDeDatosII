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

-- ciudad_kp_2
-- la clave preservada es id_ciudad de la tabla ciudad.
-- los atributos actualizables son

------------
-- INSERT --
------------
CREATE OR REPLACE FUNCTION fn_ins_ciudad_kp_2()
RETURNS TRIGGER AS $$
BEGIN
    --IF (NOT EXISTS ( SELECT 1 FROM ciudad_pel WHERE id_ciudad = new.id_ciudad )) AND
    --   EXISTS (SELECT 1 FROM pais_pel WHERE id_pais = new.id_pais) THEN
    --    INSERT INTO ciudad_pel (id_ciudad, nombre_ciudad, id_pais) VALUES (new.id_ciudad, new.nombre_ciudad, new.id_pais);

    --end if;
    IF EXISTS (SELECT 1 FROM pais_pel WHERE id_pais = new.id_pais) THEN
        IF (NOT EXISTS ( SELECT 1 FROM ciudad_pel WHERE id_ciudad = new.id_ciudad )) THEN
            INSERT INTO ciudad_pel (id_ciudad, nombre_ciudad, id_pais) VALUES (new.id_ciudad, new.nombre_ciudad, new.id_pais);
        ELSE
            RAISE EXCEPTION 'La ciudad ya existe';
        end if;

    ELSE
        RAISE EXCEPTION 'El pais no existe';
    end if;
    RETURN new;
end;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER tr_ins_ciudad_kp_2
INSTEAD OF INSERT ON ciudad_kp_2
FOR EACH ROW
EXECUTE FUNCTION fn_ins_ciudad_kp_2();

------------
-- DELETE --
------------
CREATE OR REPLACE FUNCTION fn_del_ciudad_kp_2()
RETURNS TRIGGER AS $$
BEGIN
    DELETE from ciudad_pel
    WHERE id_ciudad = old.ciudad;
    RETURN old;
end;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER tr_del_ciudad_kp_2
INSTEAD OF DELETE ON ciudad_kp_2
FOR EACH ROW
EXECUTE FUNCTION fn_del_ciudad_kp_2();

------------
-- UPDATE --
------------
CREATE OR REPLACE FUNCTION fn_upd_ciudad_kp_2()
RETURNS TRIGGER AS $$
BEGIN
    IF (new.nombre_ciudad != old.nombre_ciudad) THEN
        UPDATE ciudad_pel set nombre_ciudad = new.nombre_ciudad where id_ciudad = new.id_ciudad;
    end if;
    IF (new.id_pais != old.id_pais) THEN
        UPDATE ciudad_pel set id_pais = new.id_pais where id_ciudad = new.id_ciudad;
    end if;
    RETURN new;
end;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER tr_upd_ciudad_kp_2
INSTEAD OF UPDATE ON ciudad_kp_2
FOR EACH ROW
EXECUTE FUNCTION fn_upd_ciudad_kp_2();
-- Si se quiere cambiar el nombre_ciudad, se actualiza en la tabla ciudad
-- Si se quiere cambiar el id_pais, cambia el id_pais en ciudad, luego el nombre_pais cambia automaticamente? ya que tomaria el del nuevo id_pais en la tabla pais.
-- Podria llegar a querer cambiar el id_ciudad o id_pais?
----------------------------------------------------------------------------------------------------------------------------

CREATE VIEW entregas_kp_3 AS
SELECT nro_entrega, re.codigo_pelicula, cantidad, titulo
FROM renglon_entrega_pel re JOIN pelicula_pel p using (codigo_pelicula);

-- entregas_kp_3
-- la clave preservada es nro_entrega de la tabla renglon_entrega_pel
-- atributos actualizables?


------------
-- INSERT --
------------
CREATE OR REPLACE FUNCTION fn_ins_entregas_kp_3()
RETURNS TRIGGER AS $$
BEGIN

end;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER tr_ins_entregas_kp_3
INSTEAD OF INSERT ON entregas_kp_3
FOR EACH ROW
EXECUTE FUNCTION fn_ins_entregas_kp_3();