-- 1b

---------------------------INSERT EN COMPROBANTE---------------------------
CREATE OR REPLACE FUNCTION fn_comprobante_importe_insert()
    RETURNS TRIGGER AS $$
BEGIN
    IF(new.importe != 0) THEN
        RAISE EXCEPTION 'El importe de un comprobante nuevo debe ser de $0';
    END IF;
    return new;
END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE TRIGGER tr_comprobante_importe_insert
    BEFORE INSERT ON Comprobante
    FOR EACH ROW EXECUTE FUNCTION fn_comprobante_importe_insert();


---------------------------UPDATE EN COMPROBANTE---------------------------
CREATE OR REPLACE FUNCTION fn_comprobante_importe_update()
    RETURNS TRIGGER AS $$
BEGIN
    IF(new.importe != (SELECT SUM(l.importe) FROM lineacomprobante l WHERE l.id_comp = new.id_comp and l.id_comp = new.id_comp)) THEN
        RAISE EXCEPTION 'El valor de importe debe coincidir con la suma de los importes de las lineas del comprobante';
    END IF;
    return new;
END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE TRIGGER tr_comprobante_importe_update
    BEFORE UPDATE OF importe ON Comprobante
    FOR EACH ROW EXECUTE FUNCTION fn_comprobante_importe_update();


---------------------------INSERT EN LINEA---------------------------
CREATE OR REPLACE FUNCTION fn_linea_importe_insert()
    RETURNS TRIGGER AS $$
BEGIN
    UPDATE Comprobante SET importe = importe + new.importe WHERE id_comp = new.id_comp AND id_tcomp = new.id_tcomp;
    return new;
END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE TRIGGER tr_linea_importe_insert
    BEFORE INSERT ON LineaComprobante
    FOR EACH ROW EXECUTE FUNCTION fn_linea_importe_insert();


---------------------------UPDATE EN LINEA---------------------------
CREATE OR REPLACE FUNCTION fn_linea_importe_update()
    RETURNS TRIGGER AS $$
BEGIN
    IF(new.id_comp = old.id_comp and new.id_tcomp = old.id_tcomp) THEN
        UPDATE Comprobante SET importe = importe - old.importe + new.importe WHERE id_comp = new.id_comp AND id_tcomp = new.id_tcomp;
    ELSE
        UPDATE Comprobante SET importe = importe - old.importe  WHERE id_comp = old.id_comp AND id_tcomp = old.id_tcomp;
        UPDATE Comprobante SET importe = importe + new.importe  WHERE id_comp = new.id_comp AND id_tcomp = new.id_tcomp;
    END IF;
    return new;
END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE TRIGGER tr_linea_importe_update
    BEFORE UPDATE OF importe,id_tcomp,id_comp ON LineaComprobante
    FOR EACH ROW EXECUTE FUNCTION fn_linea_importe_update();


---------------------------DELETE EN LINEA---------------------------
CREATE OR REPLACE FUNCTION fn_linea_importe_delete()
    RETURNS TRIGGER AS $$
BEGIN
    UPDATE Comprobante SET importe = importe - old.importe WHERE id_comp = old.id_comp AND id_tcomp = old.id_tcomp;
    return old;
END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE TRIGGER tr_linea_importe_delete
    after DELETE  ON LineaComprobante
    FOR EACH ROW EXECUTE FUNCTION fn_linea_importe_delete();

--CAMBIE EL TRIGGER DELETE A AFTER PORQUE SINO LA CONDICION SIEMPRE DABA FALSE YA QUE TODAVIA NO SE HABIA ELIMINADO DE LA TABLA
--CAMBIE LA FUNCION DEL UPDATE NE COMPROBANTE, AHORA VEIRIFCO MEJOR, ANTES SIEMPRE DABA FALSO