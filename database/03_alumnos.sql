-- =====================================================
-- R.I.C. | Script 03 | Alumnos y asignación a grupos
-- Ejecutar después de 02_crear_tablas.sql
-- MySQL 8.0.45
-- =====================================================

USE ric_db;

-- -----------------------------------------------------
-- TABLA: alumnos
-- Almacena la información general de cada estudiante.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS alumnos (
    id_alumno INT AUTO_INCREMENT PRIMARY KEY,
    matricula VARCHAR(30) NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE,
    estado BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_alumnos_matricula UNIQUE (matricula)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- TABLA: alumnos_grupos
-- Conserva la relación del alumno con sus grupos y ciclos.
-- No se elimina la asignación anterior al cambiar de grupo.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS alumnos_grupos (
    id_alumno_grupo INT AUTO_INCREMENT PRIMARY KEY,
    id_alumno INT NOT NULL,
    id_grupo INT NOT NULL,
    fecha_asignacion DATE NOT NULL,
    fecha_retiro DATE,
    estado BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_alumno_grupo_alumno
        FOREIGN KEY (id_alumno)
        REFERENCES alumnos(id_alumno)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_alumno_grupo_grupo
        FOREIGN KEY (id_grupo)
        REFERENCES grupos(id_grupo)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_fechas_alumno_grupo
        CHECK (
            fecha_retiro IS NULL
            OR fecha_retiro >= fecha_asignacion
        )
) ENGINE=InnoDB;
