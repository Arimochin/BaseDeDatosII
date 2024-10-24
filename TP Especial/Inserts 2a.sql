INSERT INTO tipocomprobante(id_tcomp, nombre, tipo) values (1, 'Factura', 'Factura');

INSERT INTO persona (id_persona, tipo, tipodoc, nrodoc, nombre, apellido, fecha_nacimiento, fecha_alta, fecha_baja, cuit, activo, mail, telef_area, telef_numero)
values (1, 'P', 'DNI', '45098345', 'Juanito', 'Gonzales', '2000-03-12', '2023-11-26', '2024-07-17', '2545098345', false, null, null, null);

INSERT INTO persona (id_persona, tipo, tipodoc, nrodoc, nombre, apellido, fecha_nacimiento, fecha_alta, fecha_baja, cuit, activo, mail, telef_area, telef_numero)
values (2, 'P', 'DNI', '45098346', 'Jose', 'Martinez', '2000-11-12', '2023-03-26', null, '2545098346', true, null, null, null);

INSERT INTO cliente(id_cliente, saldo) values (1, null);

INSERT INTO cliente(id_cliente, saldo) values (2, null);

INSERT INTO categoria(id_cat, nombre) values (1, 'Categoria 1');

INSERT INTO servicio(id_servicio, nombre, periodico, costo, intervalo, tipo_intervalo, activo, id_cat)
VALUES (1, 'Internet 50 MB', true, 20000, null, null, true, 1);

INSERT INTO servicio(id_servicio, nombre, periodico, costo, intervalo, tipo_intervalo, activo, id_cat)
VALUES (2, 'Direcciones IP', true, 40000, null, null, true, 1);

INSERT INTO equipo(id_equipo, nombre, mac, ip, ap, id_servicio, id_cliente, fecha_alta, fecha_baja, tipo_conexion, tipo_asignacion)
VALUES (1, 'Router 50 MB', '23:4f:45:45', null, null, 1, 1, current_timestamp, null, null, null);

INSERT INTO equipo(id_equipo, nombre, mac, ip, ap, id_servicio, id_cliente, fecha_alta, fecha_baja, tipo_conexion, tipo_asignacion)
VALUES (2, 'Equipo 2', '23:4f:45:35', null, null, 2, 2, current_timestamp, null, null, null);

