CREATE OR REPLACE FUNCTION autoIncremento()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE empleado_1 SET
      sueldo = sueldo + (SELECT min(sueldo)*0.05 FROM empleado_1);
  RETURN new;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_autoincremento
BEFORE INSERT ON Empleado_1
FOR EACH STATEMENT
EXECUTE FUNCTION autoIncremento();

CREATE TABLE empleado_1 (
    id_empleado int,
    nombre varchar,
    apellido varchar,
    sueldo int
);

CREATE TABLE empleado_2 (
    id_empleado int,
    nombre varchar,
    apellido varchar,
    sueldo int
);

INSERT into empleado_1 (id_empleado, nombre, apellido, sueldo) VALUES (1, null, null, 500);
INSERT into empleado_2 (id_empleado, nombre, apellido, sueldo) VALUES (2, null, null, 700);
INSERT into empleado_2 (id_empleado, nombre, apellido, sueldo) VALUES (3, null, null, 300);
INSERT into empleado_2 (id_empleado, nombre, apellido, sueldo) VALUES (4, null, null, 700);

INSERT INTO empleado_1 SELECT * FROM empleado_2;

DELETE FROM empleado_1;