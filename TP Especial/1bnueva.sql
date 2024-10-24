-- 1b nueva
--b. El importe de un comprobante debe coincidir con el total de los
-- importes indicados en las líneas que lo conforman (si las tuviera).

CREATE OR REPLACE FUNCTION fn_tr_importe_lineas()
RETURNS TRIGGER AS $$
    BEGIN
        IF ( EXISTS (SELECT 1
                     FROM comprobante c
                     WHERE c.importe != (SELECT sum(l.importe)
                                         FROM lineacomprobante l
                                         WHERE c.id_comp = l.id_comp
                                           AND c.id_tcomp = l.id_tcomp)) ) THEN

        end if;
    END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER tr_importe_lineas
    AFTER INSERT OR UPDATE of importe
    ON comprobante
    FOR EACH STATEMENT
    EXECUTE FUNCTION fn_tr_importe_lineas();


CREATE ASSERTION comprobante_coincide_linea
CHECK ( NOT EXISTS ( SELECT 1
FROM Comprobante c
WHERE c.importe != (SELECT sum(l.importe)
                    FROM lineacomprobante l
                    WHERE c.id_comp = l.id_comp
                      AND c.id_tcomp = l.id_tcomp) ) )

SELECT 1
FROM Comprobante c
WHERE c.importe != (SELECT sum(l.importe)
                    FROM lineacomprobante l
                    WHERE c.id_comp = l.id_comp
                      AND c.id_tcomp = l.id_tcomp);

