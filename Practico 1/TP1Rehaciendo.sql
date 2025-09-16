-- 1
-- Muestre el apellido, nombre, las horas aportadas y la fecha de nacimiento de todos los voluntarios
-- cuya tarea sea IT_PROG o ST_CLERK y cuyas horas aportadas no sean iguales a 2.500, 3.500 ni 7.000.
-- Ordene por apellido y nombre.

SELECT apellido, nombre, horas_aportadas, fecha_nacimiento
FROM voluntario
WHERE (id_tarea = 'IT_PROG' OR id_tarea = 'ST_CLERK')
    AND horas_aportadas != 2500
    AND horas_aportadas != 3500
    AND horas_aportadas != 7000
ORDER BY apellido, nombre;

SELECT *
FROM voluntario;

-- 2
-- Genere un listado ordenado por número de voluntario, incluyendo también el nombre y apellido y
-- el e-mail de los voluntarios con menos de 10000 horas aportadas. Coloque como encabezado de las
-- columnas los títulos ‘Numero’, 'Nombre y apellido' y 'Contacto'.

SELECT nro_voluntario AS "Numero", nombre || ' ' || apellido AS "Nombre y apellido", e_mail AS "Contacto"
FROM voluntario
WHERE horas_aportadas < 10000
ORDER BY nro_voluntario;

-- 3
-- Genere un listado de los distintos id de coordinadores en la base de Voluntariado.
-- Tenga en cuenta de no incluir el valor nulo en el resultado.

SELECT DISTINCT id_coordinador
FROM voluntario
WHERE id_coordinador IS NOT NULL;

-- 4
-- Muestre los códigos de las diferentes tareas que están desarrollando los voluntarios
-- que no registran porcentaje de donación.

SELECT DISTINCT id_tarea
FROM voluntario
WHERE porcentaje IS NULL;
-- Para ver si todos son null de una de las tareas que salieron.
SELECT id_tarea, porcentaje
FROM voluntario
WHERE id_tarea = 'SH_CLERK';

-- 5
-- Muestre los 5 voluntarios que poseen más horas aportadas y que hayan nacido
-- después del año 1995.

SELECT nro_voluntario, nombre, horas_aportadas, fecha_nacimiento
FROM voluntario
WHERE EXTRACT(year from fecha_nacimiento) > 1995
ORDER BY horas_aportadas DESC
LIMIT 5;

-- 6 viejo
-- Liste el id, apellido, nombre y edad (expresada en años) de los voluntarios con fecha de
-- cumpleaños en el mes actual. Limite el resultado a los 3 voluntarios de mayor edad.

SELECT nro_voluntario, apellido, nombre, extract(year from age(current_date, fecha_nacimiento)) AS edad
FROM voluntario
WHERE extract(month from fecha_nacimiento) = extract(month from current_date)
ORDER BY 4 DESC
LIMIT 3;

-- 6 nuevo
-- Liste el id, apellido, nombre y edad de los voluntarios de entre 40 y 50 años, con fecha de
-- cumpleaños en el mes actual. Limite el resultado a los 3 voluntarios de mayor edad.
SELECT nro_voluntario, apellido, nombre, extract(year from age(current_date, fecha_nacimiento)) AS edad
FROM voluntario
WHERE extract(month from fecha_nacimiento) = extract(month from current_date)
    AND extract(year from age(current_date, fecha_nacimiento)) BETWEEN 40 AND 50
ORDER BY 4 DESC
LIMIT 3;

-- 7
-- Encuentre la cantidad mínima, máxima y promedio de horas aportadas por los voluntarios
-- de más de 30 años.

SELECT min(horas_aportadas), max(horas_aportadas), avg(horas_aportadas)
FROM voluntario
WHERE extract(year from age(current_date, fecha_nacimiento)) > 30;

-- 8
-- Por cada institución con identificador conocido, indicar la cantidad de voluntarios que trabajan
-- en ella y el total de horas que aportan.

SELECT id_institucion, count(*) as cantidad_voluntarios, sum(horas_aportadas) as suma_horas_aportadas
FROM voluntario
WHERE id_institucion IS NOT NULL
GROUP BY id_institucion;

-- 9
-- Muestre el identificador de las instituciones y la cantidad de voluntarios que trabajan en
-- ellas, sólo de aquellas instituciones que tengan más de 10 voluntarios.

SELECT id_institucion, count(*) as cantidad_voluntarios
FROM voluntario
WHERE id_institucion IS NOT NULL
GROUP BY id_institucion
HAVING count(*) > 10;

-- 10
-- Liste los coordinadores que tienen a su cargo más de 3 voluntarios dentro de una misma institución.

SELECT id_coordinador, count(*) as cant_voluntarios
FROM voluntario
GROUP BY id_coordinador, id_institucion
HAVING count(*) > 3;

--- Ahora usando esquema peliculas

-- 11
-- Muestre los ids, nombres y apellidos de los empleados que no poseen jefe. Incluya también el
-- nombre de la tarea que cada uno realiza, verificando que el sueldo máximo de la misma
-- sea superior a 14800.

SELECT e.id_empleado, e.nombre, e.apellido, t.nombre_tarea
FROM empleado e JOIN tarea t USING(id_tarea)
WHERE e.id_jefe IS NULL
    AND t.sueldo_maximo > 14800;

-- 12
-- Determine si hay empleados que reciben un sueldo superior al de sus respectivos jefes.

SELECT e.id_empleado, e.sueldo, e.id_jefe, j.id_empleado, j.sueldo
FROM empleado e JOIN empleado j ON e.id_jefe = j.id_empleado
WHERE e.sueldo > j.sueldo;

-- 13
-- Liste el identificador, nombre y tipo de los distribuidores que hayan entregado películas
-- en idioma Español luego del año 2010. Incluya en cada caso la cantidad de películas
-- distintas entregadas.

SELECT d.id_distribuidor, d.nombre, d.tipo, count(DISTINCT p.codigo_pelicula)
FROM distribuidor d JOIN entrega e USING(id_distribuidor)
                    JOIN renglon_entrega r USING(nro_entrega)
                    JOIN pelicula p USING(codigo_pelicula)
WHERE p.idioma = 'Español' AND extract(year from e.fecha_entrega) > 2010
GROUP BY d.id_distribuidor, d.nombre, d.tipo;

-- 14
-- Para cada uno de los empleados registrados en la base, liste su apellido junto con el apellido
-- de su jefe, en caso de tenerlo, sino incluya la expresión ‘(no posee)’.
-- Ordene el resultado por el apellido del empleado.

SELECT e.apellido AS apellido_empleado, COALESCE(j.apellido, '(no posee)') AS apellido_jefe
FROM empleado e LEFT JOIN empleado j ON e.id_jefe = j.id_empleado
ORDER BY e.apellido;

-- 15
-- Liste el id y nombre de todos los distribuidores existentes junto con la cantidad de videos
-- a los que han realizado entregas. Ordene el resultado por dicha cantidad en forma descendente.

SELECT d.id_distribuidor, d.nombre, count(DISTINCT v.id_video) AS cant_videos
FROM distribuidor d LEFT JOIN entrega e USING(id_distribuidor)
                    LEFT JOIN video v USING(id_video)
GROUP BY d.id_distribuidor, d.nombre
ORDER BY 3 DESC;

-- 16
-- Liste los datos de las películas que nunca han sido entregadas por un distribuidor nacional.

SELECT p.codigo_pelicula, p.titulo
FROM pelicula p JOIN renglon_entrega r USING(codigo_pelicula)
                JOIN entrega e USING(nro_entrega)
WHERE e.id_distribuidor NOT IN (SELECT id_distribuidor
                                FROM nacional);

-- 17
-- Indicar los departamentos (nombre e identificador completo) que tienen más de 3 empleados realizando
-- tareas de sueldo mínimo inferior a 6000. Mostrar el resultado ordenado por el id de departamento.

SELECT nombre, id_departamento, id_distribuidor
FROM departamento d
WHERE (d.id_departamento, d.id_distribuidor) IN (
    SELECT e.id_departamento, e.id_distribuidor
    FROM empleado e
    WHERE id_tarea IN (SELECT id_tarea
                       FROM tarea
                       WHERE sueldo_minimo < 6000)
    GROUP BY e.id_departamento, e.id_distribuidor
    HAVING count(id_empleado) > 3)
ORDER BY id_departamento;

-- 18
-- Liste los datos de los Departamentos en los que trabajan menos del 10 % de los empleados registrados.

SELECT d.nombre, d.id_departamento, d.id_distribuidor
FROM departamento d
WHERE (d.id_departamento, d.id_distribuidor) IN (
    SELECT e.id_departamento, e.id_distribuidor
    FROM empleado e
    GROUP BY e.id_departamento, e.id_distribuidor
    HAVING count(e.id_empleado) < 0.1 * (SELECT count(*)
                                         FROM empleado) );

-- 19
-- Encuentre el/los departamento/s con la mayor cantidad de empleados.

SELECT d.nombre, d.id_departamento
FROM departamento d
WHERE d.id_departamento IN (SELECT e.id_departamento
                            FROM empleado e
                            GROUP BY e.id_departamento
                            ORDER BY count(e.id_empleado))

SELECT d.nombre, d.id_departamento
FROM departamento d
WHERE EXISTS (SELECT 1
              FROM empleado e
              GROUP BY e.id_departamento
              HAVING count(*) = (SELECT max()));

SELECT d.nombre, d.id_departamento
FROM departamento d JOIN empleado e USING(id_departamento)
GROUP BY d.id_departamento, d.id_distribuidor, d.nombre
ORDER BY count(*) DESC ;