-- En el esquema de Películas, se desea llevar otra tabla histórica en la cual conste, para cada EMPLEADO,
-- el tiempo que ha permanecido en el sistema y el tiempo promedio en cada departamento.

CREATE TABLE his_empleado (
    id_empleado numeric(6),
    tiempo_en_sistema time,
    id_departamento numeric(4),
    tiempo_departamento time
);

-- Plantee los cambios necesarios en el esquema para contemplar ambos datos (mediante la/s sentencia/s SQL necesaria/s) y luego:
---- Implemente este control mediante trigger/s
---- Plantee un stored procedure que realice esta actualización
---- ¿Ambos enfoques garantizan tener actualizada en todo momento la información?
---- ¿Qué ocurriría con la información pre-existente en la base de datos al momento de incorporar el trigger o procedimiento?
---- Analice si se podría implementar lo anterior mediante chequeos declarativos (de tabla o generales)


