
-- CHINOOK - VENTA CON ROLLBACK TOTAL
-- Archivo: 02_rollback_total.sql
-- PostgreSQL 18



-- 1. COMPROBAR QUE LA CANCION NO EXISTE

-- Se utiliza un ID que no debe existir en track.

SELECT *
FROM track
WHERE track_id = -999999;


-- 2. INICIAR LA TRANSACCION

BEGIN;


-- 3. CREAR UNA FACTURA NUEVA

-- Se selecciona un cliente existente.

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
RETURNING invoice_id;


-- 4. AGREGAR UN DETALLE VALIDO

-- Se utiliza una cancion existente.

INSERT INTO invoice_line (
    invoice_id,
    track_id,
    unit_price,
    quantity
)
SELECT
    currval(pg_get_serial_sequence('invoice', 'invoice_id'))::INTEGER,
    track_id,
    unit_price,
    1
FROM track
ORDER BY track_id
LIMIT 1;


-- 5. INTENTAR AGREGAR UN DETALLE INVALIDO

-- Este ID no existe y provocara un error de clave foranea.

INSERT INTO invoice_line (
    invoice_id,
    track_id,
    unit_price,
    quantity
)
VALUES (
    currval(pg_get_serial_sequence('invoice', 'invoice_id'))::INTEGER,
    -999999,
    0.99,
    1
);



-- 6. RECUPERAR LA TRANSACCION


-- Despues del error, la transaccion queda abortada.
-- Se ejecuta ROLLBACK para cancelar toda la venta.

ROLLBACK;



-- 7. COMPROBAR QUE LA FACTURA NO EXISTE


-- currval conserva el ID generado aunque se haya hecho ROLLBACK.

SELECT
    invoice_id,
    customer_id,
    total
FROM invoice
WHERE invoice_id =
    currval(pg_get_serial_sequence('invoice', 'invoice_id'))::INTEGER;



-- 8. COMPROBAR QUE NO QUEDARON DETALLES


SELECT
    invoice_line_id,
    invoice_id,
    track_id,
    unit_price,
    quantity
FROM invoice_line
WHERE invoice_id =
    currval(pg_get_serial_sequence('invoice', 'invoice_id'))::INTEGER;

