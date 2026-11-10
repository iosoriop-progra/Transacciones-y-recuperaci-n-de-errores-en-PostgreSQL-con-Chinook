# Transacciones-y-recuperaci-n-de-errores-en-PostgreSQL-con-Chinook
Implementar y demostrar una operación de venta atómica en PostgreSQL con Chinook, incluyendo confirmación, reversión total, recuperación parcial y visibilidad entre sesiones. La evaluación se centra en el control transaccional y en la evidencia de sus resultados.


# Transacciones y recuperación de errores en PostgreSQL con Chinook

## 1. Descripción

Este proyecto consiste en realizar operaciones de venta utilizando la base de datos Chinook en PostgreSQL 18.

El objetivo es practicar el manejo de transacciones mediante BEGIN, COMMIT, ROLLBACK y SAVEPOINT, comprobando que los datos se guarden correctamente o se reviertan cuando ocurre un error.

## 2. Herramientas utilizadas

- PostgreSQL 18.
- Base de datos Chinook.
- DataGrip o cliente SQL compatible.
- Git y GitHub.

## 3. Base de datos


Para preparar la base de datos se debe revisar el script de importación y ejecutarlo en una base local dedicada, ya que contiene instrucciones para eliminar y crear la base.

## 4. Archivos del proyecto

- `01_venta_exitosa.sql`: registra una venta y confirma la transacción.
- `02_rollback_total.sql`: demuestra cómo cancelar una venta cuando ocurre un error.
- `03_savepoint.sql`: permite recuperar una parte de la transacción sin perder los detalles anteriores.
- `04_validaciones.sql`: contiene consultas para comprobar los resultados.

## 5. Ejecución

Los archivos deben ejecutarse en el siguiente orden:

1. `01_venta_exitosa.sql`
2. `02_rollback_total.sql`
3. `03_savepoint.sql`
4. `04_validaciones.sql`

Para demostrar la visibilidad de los datos se necesitan dos conexiones independientes:

- **Conexión A:** realiza las operaciones de venta.
- **Conexión B:** consulta los datos antes y después del COMMIT.

Se utiliza el nivel de aislamiento `READ COMMITTED` y transacciones explícitas.

Antes de ejecutar las validaciones, se deben colocar los identificadores reales de las facturas generadas.

