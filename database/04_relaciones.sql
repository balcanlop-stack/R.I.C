-- R.I.C. | Script 04 | Verificar las claves foráneas
-- Las claves foráneas se crean en los scripts 02 y 03.
-- Este archivo solamente consulta las relaciones existentes.
USE ric_db;

SELECT
    TABLE_NAME AS tabla,
    COLUMN_NAME AS columna,
    CONSTRAINT_NAME AS nombre_relacion,
    REFERENCED_TABLE_NAME AS tabla_referenciada,
    REFERENCED_COLUMN_NAME AS columna_referenciada
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'ric_db'
  AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, CONSTRAINT_NAME;
