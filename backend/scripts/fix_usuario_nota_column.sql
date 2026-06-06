-- Corrige tipo de columna nota en Neon (varchar/text -> double precision).
-- Ejecutar en Neon SQL Editor si Hibernate falla al arrancar con:
--   ERROR: column "nota" cannot be cast automatically to type double precision

UPDATE usuario SET nota = '0' WHERE nota IS NULL OR trim(nota::text) = '';

ALTER TABLE usuario
    ALTER COLUMN nota TYPE double precision
    USING CASE
        WHEN nota IS NULL OR trim(nota::text) = '' THEN 0.0
        ELSE nota::double precision
    END;

ALTER TABLE usuario ALTER COLUMN nota SET DEFAULT 0.0;
