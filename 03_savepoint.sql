
-- CHINOOK - RECUPERACION CON SAVEPOINT
-- Archivo: 03_savepoint.sql
-- PostgreSQL 18



-- 1. PREPARAR EL ID DE LA FACTURA

-- Se guarda el ID para utilizarlo durante la transaccion.

DROP TABLE IF EXISTS venta_savepoint;

CREATE TEMP TABLE venta_savepoint (
    invoice_id INTEGER
);


-- 2. INICIAR LA TRANSACCION

BEGIN;


-- 3. CREAR UNA FACTURA NUEVA

-- Se selecciona un cliente existente.

WITH nueva_factura AS (
    INSERT INTO invoice (
        customer_id,
        invoice_date,
        billing_address,
        billing_city,
        billing_state,
        billing_country,
        billing_postal_code,
        total
    )
    SELECT
        customer_id,
        CURRENT_TIMESTAMP,
        address,
        city,
        state,
        country,
        postal_code,
        0.00
    FROM customer
    ORDER BY customer_id
    LIMIT 1
    RETURNING invoice_id
)
INSERT INTO venta_savepoint (invoice_id)
SELECT invoice_id
FROM nueva_factura;


-- 4. AGREGAR DOS DETALLES VALIDOS

-- Se utilizan dos canciones existentes.

INSERT INTO invoice_line (
    invoice_id,
    track_id,
    unit_price,
    quantity
)
SELECT
    v.invoice_id,
    t.track_id,
    t.unit_price,
    1
FROM venta_savepoint v
CROSS JOIN (
    SELECT track_id, unit_price
    FROM track
    ORDER BY track_id
    LIMIT 2
) t;


-- 5. CREAR EL PUNTO DE RECUPERACION

SAVEPOINT punto_seguro;


-- 6. INTENTAR INSERTAR UN DETALLE INVALIDO

-- Este track_id no existe y provocara un error de FK.

INSERT INTO invoice_line (
    invoice_id,
    track_id,
    unit_price,
    quantity
)
VALUES (
    (SELECT invoice_id FROM venta_savepoint),
    -999999,
    0.99,
    1
);


-- 7. RECUPERAR LOS DATOS ANTERIORES

-- Se elimina el error sin perder los dos detalles validos.

ROLLBACK TO SAVEPOINT punto_seguro;


-- 8. AGREGAR EL DETALLE CORREGIDO

-- Se selecciona una tercera cancion diferente.

INSERT INTO invoice_line (
    invoice_id,
    track_id,
    unit_price,
    quantity
)
SELECT
    v.invoice_id,
    t.track_id,
    t.unit_price,
    1
FROM venta_savepoint v
CROSS JOIN (
    SELECT track_id, unit_price
    FROM track
    WHERE track_id NOT IN (
        SELECT track_id
        FROM invoice_line
        WHERE invoice_id = (SELECT invoice_id FROM venta_savepoint)
    )
    ORDER BY track_id
    LIMIT 1
) t;


-- 9. ACTUALIZAR EL TOTAL DE LA FACTURA

-- Se calcula utilizando los detalles guardados.

UPDATE invoice
SET total = (
    SELECT SUM(unit_price * quantity)
    FROM invoice_line
    WHERE invoice_id = (SELECT invoice_id FROM venta_savepoint)
)
WHERE invoice_id = (SELECT invoice_id FROM venta_savepoint);


-- 10. COMPROBAR LOS DETALLES DE LA VENTA

SELECT
    invoice_line_id,
    invoice_id,
    track_id,
    unit_price,
    quantity
FROM invoice_line
WHERE invoice_id = (SELECT invoice_id FROM venta_savepoint)
ORDER BY invoice_line_id;


-- 11. COMPROBAR LA CANTIDAD Y EL TOTAL

SELECT
    i.invoice_id,
    COUNT(il.invoice_line_id) AS cantidad_detalles,
    i.total AS total_factura,
    SUM(il.unit_price * il.quantity) AS total_calculado,
    i.total = SUM(il.unit_price * il.quantity) AS total_correcto
FROM invoice i
INNER JOIN invoice_line il
    ON i.invoice_id = il.invoice_id
WHERE i.invoice_id = (SELECT invoice_id FROM venta_savepoint)
GROUP BY i.invoice_id, i.total;


-- 12. CONFIRMAR LA VENTA

COMMIT;


-- 13. MOSTRAR EL ID DE LA FACTURA CREADA

SELECT invoice_id AS factura_creada
FROM venta_savepoint;

