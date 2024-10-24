-- a. Las personas que no están activas deben tener establecida una fecha de baja,
-- la cual se debe controlar que sea al menos 6 meses posterior a la de su alta.


ALTER TABLE Persona
   ADD CONSTRAINT fecha_alta_baja_6m
       CHECK ( ( activo = FALSE AND (fecha_baja is not null AND (DATE_PART('months', AGE(fecha_baja, fecha_alta)) >= 6 ) ) )
                OR activo = TRUE );
-- Si esta activo hay que verificar que no tenga fecha de baja?

INSERT INTO persona (id_persona, tipo, tipodoc, nrodoc, nombre, apellido, fecha_nacimiento, fecha_alta, fecha_baja, cuit, activo, mail, telef_area, telef_numero)
values (1, 'P', 'DNI', '45098345', 'Juanito', 'Gonzales', '2000-03-12', '2023-11-26', '2024-04-17', '2545098345', false, null, null, null);


--DATE_PART('months',AGE(fecha_baja,fecha_alta))

