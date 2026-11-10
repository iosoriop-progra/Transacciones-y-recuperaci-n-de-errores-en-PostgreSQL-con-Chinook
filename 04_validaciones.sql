
-- CHINOOK - VALIDACION DE LAS VENTAS
-- Archivo: 04_validaciones.sql
-- PostgreSQL 18



-- 1. COMPROBAR LA CONEXION

SELECT
    pg_backend_pid() AS identificador_sesion;

SHOW transaction_isolation;


-- 2. COMPROBAR LA VENTA EXITOSA

-- Reemplazar 0 por el ID de la primera factura creada.

SELECT
    i.invoice_id,
    i.customer_id,
    i.invoice_date,
    i.total AS total_factura,
    COUNT(il.invoice_line_id) AS cantidad_detalles,
    SUM(il.unit_price * il.quantity) AS total_calculado,
    i.total = SUM(il.unit_price * il.quantity) AS total_correcto
FROM invoice i
INNER JOIN invoice_line il
    ON i.invoice_id = il.invoice_id
WHERE i.invoice_id = 0
GROUP BY
    i.invoice_id,
    i.customer_id,
    i.invoice_date,
    i.total;


-- 3. MOSTRAR LOS DETALLES DE LA VENTA EXITOSA

SELECT
    il.invoice_line_id,
    il.invoice_id,
    t.name AS cancion,
    il.unit_price AS precio,
    il.quantity AS cantidad
FROM invoice_line il
INNER JOIN track t
    ON il.track_id = t.track_id
WHERE il.invoice_id = 0
ORDER BY il.invoice_line_id;


-- 4. COMPROBAR LA VENTA CON ROLLBACK

-- Reemplazar 0 por el ID de la factura que se revirtio.
-- El resultado esperado es cero registros.

SELECT
    invoice_id,
    customer_id,
    total
FROM invoice
WHERE invoice_id = 0;


-- Comprobar que tampoco quedaron detalles.

SELECT
    invoice_line_id,
    invoice_id,
    track_id
FROM invoice_line
WHERE invoice_id = 0;


-- 5. COMPROBAR LA VENTA CON SAVEPOINT

-- Reemplazar 0 por el ID de la tercera factura creada.

SELECT
    i.invoice_id,
    i.customer_id,
    i.total AS total_factura,
    COUNT(il.invoice_line_id) AS cantidad_detalles,
    SUM(il.unit_price * il.quantity) AS total_calculado,
    i.total = SUM(il.unit_price * il.quantity) AS total_correcto
FROM invoice i
INNER JOIN invoice_line il
    ON i.invoice_id = il.invoice_id
WHERE i.invoice_id = 0
GROUP BY
    i.invoice_id,
    i.customer_id,
    i.total;


-- 6. MOSTRAR LOS DETALLES RECUPERADOS

SELECT
    invoice_line_id,
    invoice_id,
    track_id,
    unit_price,
    quantity
FROM invoice_line
WHERE invoice_id = 0
ORDER BY invoice_line_id;


-- 7. COMPROBAR LA CANTIDAD DE DETALLES

SELECT
    invoice_id,
    COUNT(*) AS total_detalles
FROM invoice_line
WHERE invoice_id = 0
GROUP BY invoice_id;


-- 8. COMPROBAR QUE LOS DATOS ESTAN RELACIONADOS

SELECT
    i.invoice_id,
    c.first_name AS nombre_cliente,
    c.last_name AS apellido_cliente,
    t.name AS cancion,
    il.unit_price AS precio,
    il.quantity AS cantidad,
    i.total AS total_factura
FROM invoice i
INNER JOIN customer c
    ON i.customer_id = c.customer_id
INNER JOIN invoice_line il
    ON i.invoice_id = il.invoice_id
INNER JOIN track t
    ON il.track_id = t.track_id
WHERE i.invoice_id = 0
ORDER BY il.invoice_line_id;


-- 9. COMPROBAR QUE LOS DETALLES TIENEN CANTIDADES POSITIVAS

SELECT
    invoice_line_id,
    track_id,
    quantity
FROM invoice_line
WHERE quantity <= 0;


-- 10. COMPROBAR QUE NO EXISTEN DETALLES SIN FACTURA

SELECT
    il.invoice_line_id,
    il.invoice_id
FROM invoice_line il
LEFT JOIN invoice i
    ON il.invoice_id = i.invoice_id
WHERE i.invoice_id IS NULL;

