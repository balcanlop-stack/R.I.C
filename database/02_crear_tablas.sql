-- R.I.C. | Script 02 | Usuarios y estructura académica
-- Ejecutar después de 01_crear_base_datos.sql
USE ric_db;

CREATE TABLE IF NOT EXISTS usuarios (
  id_usuario INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  correo VARCHAR(120) NOT NULL,
  contrasena_hash VARCHAR(255) NOT NULL,
  rol ENUM('DIRECTOR','PROFESOR') NOT NULL,
  estado BOOLEAN NOT NULL DEFAULT TRUE,
  fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uq_usuarios_correo UNIQUE (correo)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS profesores (
  id_profesor INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario INT NOT NULL,
  numero_empleado VARCHAR(30),
  CONSTRAINT uq_profesores_usuario UNIQUE (id_usuario),
  CONSTRAINT uq_profesores_numero_empleado UNIQUE (numero_empleado),
  CONSTRAINT fk_profesores_usuario FOREIGN KEY (id_usuario)
    REFERENCES usuarios(id_usuario)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS niveles_educativos (
  id_nivel INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(80) NOT NULL,
  descripcion VARCHAR(255),
  estado BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT uq_niveles_nombre UNIQUE (nombre)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ciclos_escolares (
  id_ciclo INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(30) NOT NULL,
  fecha_inicio DATE NOT NULL,
  fecha_fin DATE NOT NULL,
  estado BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT uq_ciclos_nombre UNIQUE (nombre),
  CONSTRAINT chk_ciclos_fechas CHECK (fecha_fin > fecha_inicio)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS grados (
  id_grado INT AUTO_INCREMENT PRIMARY KEY,
  id_nivel INT NOT NULL,
  nombre VARCHAR(50) NOT NULL,
  CONSTRAINT fk_grados_nivel FOREIGN KEY (id_nivel)
    REFERENCES niveles_educativos(id_nivel)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT uq_grados_nivel_nombre UNIQUE (id_nivel, nombre)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS grupos (
  id_grupo INT AUTO_INCREMENT PRIMARY KEY,
  id_grado INT NOT NULL,
  id_ciclo INT NOT NULL,
  nombre VARCHAR(20) NOT NULL,
  estado BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT fk_grupos_grado FOREIGN KEY (id_grado)
    REFERENCES grados(id_grado)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_grupos_ciclo FOREIGN KEY (id_ciclo)
    REFERENCES ciclos_escolares(id_ciclo)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT uq_grupos_grado_ciclo_nombre
    UNIQUE (id_grado, id_ciclo, nombre)
) ENGINE=InnoDB;
