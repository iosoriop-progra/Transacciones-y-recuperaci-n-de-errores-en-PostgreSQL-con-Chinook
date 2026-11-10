

-- CONECTATECH / CHINOOK
-- ARCHIVO 01: VENTA EXITOSA
-- PostgreSQL 18



-- 1. INFORMACION DE LA CONEXION A

-- Se muestra el identificador de la conexion.
SELECT
    pg_backend_pid() AS conexion_A;

-- Se comprueba el nivel de aislamiento.
SHOW transaction_isolation;


-- 2. INICIAR LA VENTA

BEGIN;

-- Tabla temporal para guardar el ID de la factura nueva.
CREATE TEMP TABLE venta_actual (
    invoice_id INTEGER
) ON COMMIT DROP;


-- 3. CREAR LA FACTURA

-- Se selecciona un cliente que ya existe en Chinook.
-- RETURNING permite recuperar el ID generado.

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
INSERT INTO venta_actual (invoice_id)
SELECT invoice_id
FROM nueva_factura;


-- 4. AGREGAR TRES CANCIONES A LA FACTURA

-- Se utilizan tres canciones que ya existen en Chinook.
-- La cantidad de cada cancion es 1.

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
FROM venta_actual v
CROSS JOIN (
    SELECT track_id, unit_price
    FROM track
    ORDER BY track_id
    LIMIT 3
) t;


-- 5. CALCULAR EL TOTAL DE LA FACTURA

-- El total se obtiene sumando el precio por la cantidad.

UPDATE invoice
SET total = (
    SELECT SUM(unit_price * quantity)
    FROM invoice_line
    WHERE invoice_id = (SELECT invoice_id FROM venta_actual)
)
WHERE invoice_id = (SELECT invoice_id FROM venta_actual);


-- 6. MOSTRAR EL ID DE LA FACTURA

-- Guardar este numero para consultarlo despues en la conexion B.

SELECT invoice_id AS factura_creada
FROM venta_actual;


-- 7. MOSTRAR LOS DETALLES DE LA VENTA

SELECT
    il.invoice_line_id,
    il.invoice_id,
    il.track_id,
    t.name AS cancion,
    il.unit_price AS precio,
    il.quantity AS cantidad
FROM invoice_line il
INNER JOIN track t
    ON il.track_id = t.track_id
WHERE il.invoice_id = (SELECT invoice_id FROM venta_actual)
ORDER BY il.invoice_line_id;


-- 8. COMPROBAR EL TOTAL Y LA CANTIDAD DE DETALLES

SELECT
    i.invoice_id,
    COUNT(il.invoice_line_id) AS cantidad_detalles,
    i.total AS total_factura,
    SUM(il.unit_price * il.quantity) AS total_calculado,
    i.total = SUM(il.unit_price * il.quantity) AS total_correcto
FROM invoice i
INNER JOIN invoice_line il
    ON i.invoice_id = il.invoice_id
WHERE i.invoice_id = (SELECT invoice_id FROM venta_actual)
GROUP BY i.invoice_id, i.total;


-- 9. CONFIRMAR LA VENTA

-- Si las comprobaciones son correctas, se confirma la transaccion.

COMMIT;



-- 10. VERIFICACION DESDE LA CONEXION B


-- IMPORTANTE:
-- Abrir una segunda conexion independiente en DataGrip.
-- Ejecutar estas consultas DESPUES del COMMIT de la conexion A.
-- Reemplazar el 0 por el invoice_id obtenido en el apartado 6.

-- Mostrar el identificador de la conexion B.

SELECT
    pg_backend_pid() AS conexion_B;

-- Comprobar el aislamiento de la conexion B.

SHOW transaction_isolation;


-- Comprobar que la factura ya esta guardada.

SELECT
    invoice_id,
    customer_id,
    invoice_date,
    total
FROM invoice
WHERE invoice_id = 0;


-- Comprobar los detalles de la factura.

SELECT
    invoice_line_id,
    invoice_id,
    track_id,
    unit_price,
    quantity
FROM invoice_line
WHERE invoice_id = 0
ORDER BY invoice_line_id;

