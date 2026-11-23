-- R.I.C. - Script 06: Asignaciones docentes y materias
-- Base de datos: ric_db | MySQL 8.0+
--
-- Este script crea tres tablas nuevas. No modifica ni elimina
-- ninguna de las ocho tablas existentes.
-- Las reglas de solapamiento de fechas y de profesor responsable
-- por materia/grupo deben validarse en Java mediante transacciones.

USE ric_db;

-- Estados de asignaciones_docentes y materias_asignadas:
-- 1 = PROGRAMADA, 2 = ACTIVA, 3 = INACTIVA, 4 = CANCELADA.
CREATE TABLE asignaciones_docentes (
    id_asignacion INT NOT NULL AUTO_INCREMENT,
    id_profesor INT NOT NULL,
    id_grupo INT NOT NULL,
    fecha_asignacion DATE NOT NULL,
    fecha_fin DATE DEFAULT NULL,
    estado TINYINT NOT NULL DEFAULT 2,
    PRIMARY KEY (id_asignacion),
    INDEX idx_asignacion_profesor (id_profesor),
    INDEX idx_asignacion_grupo (id_grupo),
    CONSTRAINT fk_asignacion_profesor
        FOREIGN KEY (id_profesor)
        REFERENCES profesores (id_profesor)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_asignacion_grupo
        FOREIGN KEY (id_grupo)
        REFERENCES grupos (id_grupo)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_fechas_asignacion
        CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_asignacion),
    CONSTRAINT chk_estado_asignacion
        CHECK (estado IN (1, 2, 3, 4))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

-- Catálogo general compartido.
-- La aplicación debe validar que id_usuario_registro corresponda
-- a un usuario con rol PROFESOR.
-- Estado: 0 = INACTIVA, 1 = ACTIVA.
CREATE TABLE materias (
    id_materia INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255) DEFAULT NULL,
    id_usuario_registro INT NOT NULL,
    estado TINYINT NOT NULL DEFAULT 1,
    PRIMARY KEY (id_materia),
    UNIQUE KEY uq_materia_nombre (nombre),
    INDEX idx_materia_usuario (id_usuario_registro),
    CONSTRAINT fk_materia_usuario
        FOREIGN KEY (id_usuario_registro)
        REFERENCES usuarios (id_usuario)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_estado_materia
        CHECK (estado IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE materias_asignadas (
    id_materia_asignada INT NOT NULL AUTO_INCREMENT,
    id_asignacion INT NOT NULL,
    id_materia INT NOT NULL,
    fecha_asignacion DATE NOT NULL,
    fecha_fin DATE DEFAULT NULL,
    estado TINYINT NOT NULL DEFAULT 2,
    PRIMARY KEY (id_materia_asignada),
    INDEX idx_materia_asignada (id_asignacion),
    INDEX idx_materia_catalogo (id_materia),
    CONSTRAINT fk_materia_asignada_asignacion
        FOREIGN KEY (id_asignacion)
        REFERENCES asignaciones_docentes (id_asignacion)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_materia_asignada_materia
        FOREIGN KEY (id_materia)
        REFERENCES materias (id_materia)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_fechas_materia
        CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_asignacion),
    CONSTRAINT chk_estado_materia_asignada
        CHECK (estado IN (1, 2, 3, 4))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

-- Antes de ejecutar:
-- 1. Confirmar que las tablas referenciadas existen.
-- 2. Confirmar que estas tres tablas aún no existen.
-- 3. Probar primero en una base de desarrollo.
-- No ejecutar el dump completo RIC_Base_de_Datos.sql para aplicar
-- estos cambios: contiene instrucciones DROP TABLE.
