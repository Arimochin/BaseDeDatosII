-- Ejercicio 4
-- Dadas las siguientes vistas sobre el esquema de Voluntarios (unc_esq_voluntario):
--
-- CREATE OR REPLACE VIEW tarea10000hs AS
-- SELECT *  FROM tarea
-- WHERE max_horas > 10000
-- WITH LOCAL CHECK OPTION;
--
-- CREATE OR REPLACE VIEW tarea10000rep AS
-- SELECT *  FROM tarea10000hs
-- WHERE id_tarea LIKE '%REP%'
-- WITH LOCAL CHECK OPTION;
--
-- a) ¿Cuál sería el resultado de las siguientes sentencias (ejecutadas en el orden dado)? Justifique.
-- 1. INSERT INTO tarea10000rep (id_tarea, nombre_tarea, min_horas, max_horas)
--      VALUES ( 'MGR', 'Org Salud', 18000, 20000);
-- 2. INSERT INTO tarea10000hs (id_tarea, nombre_tarea, min_horas, max_horas)
--      VALUES (  'REPA', 'Organiz Salud', 4000, 5500);
-- 3. INSERT INTO tarea10000rep (id_tarea, nombre_tarea, min_horas, max_horas)
--      VALUES ( 'CC_REP', 'Organizacion Salud', 8000, 9000);
-- 4. INSERT INTO tarea10000hs (id_tarea, nombre_tarea, min_horas, max_horas)
--      VALUES (  'ROM', 'Org Salud', 10000, 12000);
-- b) Luego de ejecutadas las sentencias anteriores, en qué objetos de la BD aparecen insertadas las tuplas?
-- c) Idem a) y b) pero considerando que tarea10000hs no tiene definida opción de chequeo.


CREATE OR REPLACE VIEW tarea10000hs AS
SELECT *  FROM tarea_vol
WHERE max_horas > 10000
WITH LOCAL CHECK OPTION;

CREATE OR REPLACE VIEW tarea10000rep AS
SELECT *  FROM tarea10000hs
WHERE id_tarea LIKE '%REP%'
WITH LOCAL CHECK OPTION;

INSERT INTO tarea10000rep (id_tarea, nombre_tarea, min_horas, max_horas)
VALUES ( 'MGR', 'Org Salud', 18000, 20000);

INSERT INTO tarea10000hs (id_tarea, nombre_tarea, min_horas, max_horas)
VALUES (  'REPA', 'Organiz Salud', 4000, 5500);

INSERT INTO tarea10000rep (id_tarea, nombre_tarea, min_horas, max_horas)
VALUES ( 'CC_REP', 'Organizacion Salud', 8000, 9000);

INSERT INTO tarea10000hs (id_tarea, nombre_tarea, min_horas, max_horas)
VALUES (  'ROM', 'Org Salud', 10000, 12000);

-- a)
-- 1. No la acepta, ya que id_tarea no cumple con la condicion del where. MGR no contiene REP

-- 2. No la acepta, ya que max_horas no cumple con el where. max_horas es 5500 y pide mas de 10000

-- 3. Falla. Cumple con la condicion del REP pero no cumple con la condicion de las horas de la vista subyacente

-- 4. Si pasa, cumple la condicion de max_horas > 10000

-- b)
-- La ultima tupla aparece en la tabla tarea y en la vista tarea1000hs

CREATE OR REPLACE VIEW tarea10000hs AS
SELECT *  FROM tarea_vol
WHERE max_horas > 10000;

CREATE OR REPLACE VIEW tarea10000rep AS
SELECT *  FROM tarea10000hs
WHERE id_tarea LIKE '%REP%'
WITH LOCAL CHECK OPTION;

-- c)
-- 1. Sigue fallando por la condicion en tarea10000rep

-- 2. Ahora pasa, ya que la vista no tiene opcion de chequeo. Igual no va a aparecer en la vista.

-- 3. Ahora pasa, ya que cumple con la condicion del rep. Tiene local check option por lo que solo
-- chequea la condicion de la vista actual y no de las subyacente (a menos que tenga WCO). Igual
-- no va a aparece en la vista porque esta basada en la anterior.

-- 4. Pasa igual que antes.

-- La segunda tupla se inserta en la tabla tarea ya que la vista no tiene WCO pero en la vista no se ve
-- ya que no cumple la condicion de la vista.

-- La tercera tupla se inserta en la tabla tarea, ya que tarea10000hs no tiene WCO. Pero no aparece en
-- esta vista ya que no cumple su condicion del where. Y por esto mismo tampoco aparece en la de 10000rep
-- ya que al ser una vista basada en la de 10000hs no va a aparecer.

