# R.I.C. — Diccionario de datos

**Proyecto:** Registro Integral de Calificaciones  
**Versión:** 1.0  
**Estado:** Borrador integrado para revisión técnica  
**Fecha de referencia del esquema:** 23 de noviembre de 2026  
**Motor de base de datos:** MySQL 8.0.45  
**Base de datos:** `ric_db`

## 1. Propósito y criterios

Este documento reúne la estructura física descrita en el respaldo SQL compartido y las reglas funcionales aprobadas durante el diseño.

Se distinguen:
- **Existente:** aparece en el respaldo SQL.
- **Decisión funcional aprobada:** regla acordada; no implica que ya esté implementada en MySQL.
- **Pendiente:** requiere diseño, aprobación técnica o implementación.

> El respaldo SQL es la referencia de la estructura física documentada. No se debe asumir que una regla funcional está protegida por MySQL si el respaldo no contiene la restricción correspondiente.

## 2. Resumen de tablas existentes

| N.º | Tabla | Área |
|---:|---|---|
| 1 | `usuarios` | Usuarios y acceso |
| 2 | `profesores` | Usuarios y profesores |
| 3 | `niveles_educativos` | Estructura escolar |
| 4 | `ciclos_escolares` | Estructura escolar |
| 5 | `grados` | Estructura escolar |
| 6 | `grupos` | Estructura escolar |
| 7 | `alumnos` | Alumnos |
| 8 | `alumnos_grupos` | Inscripciones |
| 9 | `asignaciones_docentes` | Asignaciones |
| 10 | `materias` | Catálogo de materias |
| 11 | `materias_asignadas` | Materias por grupo/profesor |

El respaldo compartido muestra estas once estructuras y no contiene registros de datos en ellas.

## 3. Diccionario de tablas y campos

### 3.1 `usuarios`

**Propósito:** almacenar las cuentas que pueden iniciar sesión en R.I.C.

| Campo | Tipo SQL | Nulo | Predeterminado | Clave / restricción | Descripción |
|---|---|---|---|---|---|
| `id_usuario` | `INT` | No | `AUTO_INCREMENT` | PK | Identificador único. |
| `nombre` | `VARCHAR(100)` | No | — | — | Nombre del usuario. |
| `correo` | `VARCHAR(120)` | No | — | UNIQUE | Correo de acceso; no se permiten duplicados. |
| `contrasena_hash` | `VARCHAR(255)` | No | — | — | Hash de la contraseña. |
| `rol` | `ENUM('DIRECTOR','PROFESOR')` | No | — | — | Rol de la cuenta. |
| `estado` | `TINYINT(1)` | No | `1` | — | Estado de la cuenta. |
| `fecha_creacion` | `DATETIME` | No | `CURRENT_TIMESTAMP` | — | Fecha y hora de creación. |

**Relaciones físicas:** `profesores.id_usuario` y `materias.id_usuario_registro` referencian `usuarios.id_usuario`.

**Reglas funcionales aprobadas:**
- Los roles contemplados son `DIRECTOR` y `PROFESOR`.
- El director crea los perfiles y credenciales iniciales de profesores.
- El profesor puede cambiar su contraseña.
- Las cuentas de profesores que dejan la institución se desactivan; no se eliminan físicamente.

**Observación:** el respaldo no define con una restricción los valores funcionales de `estado`. La convención `1 = ACTIVO` y `0 = INACTIVO` debe confirmarse en la especificación de cuentas antes de implementarse.

### 3.2 `profesores`

**Propósito:** almacenar la información específica del perfil docente asociado a una cuenta.

| Campo | Tipo SQL | Nulo | Predeterminado | Clave / restricción | Descripción |
|---|---|---|---|---|---|
| `id_profesor` | `INT` | No | `AUTO_INCREMENT` | PK | Identificador del profesor. |
| `id_usuario` | `INT` | No | — | FK, UNIQUE | Usuario asociado; un usuario no puede tener más de un perfil docente. |
| `numero_empleado` | `VARCHAR(30)` | Sí | `NULL` | UNIQUE | Número de empleado opcional y único cuando se registra. |

**Relación física:** `id_usuario` referencia `usuarios.id_usuario`, con `ON DELETE RESTRICT ON UPDATE CASCADE`.

**Reglas funcionales aprobadas:**
- Cada profesor debe tener una cuenta en `usuarios`.
- El director registra el perfil docente y proporciona las credenciales iniciales.
- El número de empleado es opcional.
- Los profesores no se eliminan físicamente.

### 3.3 `niveles_educativos`

**Propósito:** almacenar los niveles educativos de la institución.

| Campo | Tipo SQL | Nulo | Predeterminado | Clave / restricción | Descripción |
|---|---|---|---|---|---|
| `id_nivel` | `INT` | No | `AUTO_INCREMENT` | PK | Identificador del nivel. |
| `nombre` | `VARCHAR(80)` | No | — | UNIQUE | Nombre del nivel educativo. |
| `descripcion` | `VARCHAR(255)` | Sí | `NULL` | — | Descripción opcional. |
| `estado` | `TINYINT(1)` | No | `1` | — | Estado del nivel. |

**Relación física:** `grados.id_nivel` referencia `niveles_educativos.id_nivel`.

**Reglas funcionales aprobadas:**
- El director crea y administra los niveles educativos.
- Un nivel puede desactivarse sin eliminar sus grados.
- No se deben eliminar físicamente niveles relacionados con grados.

**Observación:** el respaldo no contiene una restricción que defina los valores permitidos de `estado`.

### 3.4 `ciclos_escolares`

**Propósito:** registrar los ciclos escolares y sus fechas.

| Campo | Tipo SQL | Nulo | Predeterminado | Clave / restricción | Descripción |
|---|---|---|---|---|---|
| `id_ciclo` | `INT` | No | `AUTO_INCREMENT` | PK | Identificador del ciclo. |
| `nombre` | `VARCHAR(30)` | No | — | UNIQUE | Nombre único del ciclo. |
| `fecha_inicio` | `DATE` | No | — | — | Inicio del ciclo. |
| `fecha_fin` | `DATE` | No | — | CHECK | Fin del ciclo; debe ser posterior al inicio. |
| `estado` | `TINYINT(1)` | No | `1` | — | Estado del ciclo. |

**Restricción física:** `chk_fechas_ciclo` exige `fecha_fin > fecha_inicio`.

**Relación física:** `grupos.id_ciclo` referencia `ciclos_escolares.id_ciclo`.

**Reglas funcionales aprobadas:**
- El director administra los ciclos escolares.
- Solamente puede existir un ciclo escolar activo a la vez.
- Los ciclos y sus registros históricos deben conservarse.

**Observación técnica:** el respaldo no contiene una restricción que garantice por sí sola que exista un solo ciclo activo. Esa regla requiere validación en la lógica de negocio y evaluación de protección adicional en base de datos.

### 3.5 `grados`

**Propósito:** registrar los grados correspondientes a cada nivel educativo.

| Campo | Tipo SQL | Nulo | Predeterminado | Clave / restricción | Descripción |
|---|---|---|---|---|---|
| `id_grado` | `INT` | No | `AUTO_INCREMENT` | PK | Identificador del grado. |
| `id_nivel` | `INT` | No | — | FK | Nivel al que pertenece. |
| `nombre` | `VARCHAR(50)` | No | — | UNIQUE compuesto | Nombre del grado. |

**Restricciones físicas:**
- `uq_grado_nivel`: combinación única de (`id_nivel`, `nombre`).
- `fk_grado_nivel`: referencia `niveles_educativos.id_nivel`, con `ON DELETE RESTRICT ON UPDATE CASCADE`.

**Reglas funcionales aprobadas:**
- El director administra los grados.
- No se elimina un grado que tenga grupos relacionados.
- Un mismo nombre puede existir en niveles diferentes, pero no repetirse dentro del mismo nivel.

### 3.6 `grupos`

**Propósito:** registrar los grupos de un grado para un ciclo escolar.

| Campo | Tipo SQL | Nulo | Predeterminado | Clave / restricción | Descripción |
|---|---|---|---|---|---|
| `id_grupo` | `INT` | No | `AUTO_INCREMENT` | PK | Identificador del grupo. |
| `id_grado` | `INT` | No | — | FK | Grado del grupo. |
| `id_ciclo` | `INT` | No | — | FK | Ciclo escolar del grupo. |
| `nombre` | `VARCHAR(20)` | No | — | UNIQUE compuesto | Nombre o identificador del grupo. |
| `estado` | `TINYINT(1)` | No | `1` | — | Estado del grupo. |

**Restricciones físicas:**
- `uq_grupo_grado_ciclo`: combinación única de (`id_grado`, `id_ciclo`, `nombre`).
- `fk_grupo_grado`: referencia `grados.id_grado`, `ON DELETE RESTRICT ON UPDATE CASCADE`.
- `fk_grupo_ciclo`: referencia `ciclos_escolares.id_ciclo`, `ON DELETE RESTRICT ON UPDATE CASCADE`.

**Relaciones físicas:** `alumnos_grupos.id_grupo` y `asignaciones_docentes.id_grupo` referencian `grupos.id_grupo`.

**Reglas funcionales aprobadas:**
- Solo el director crea y administra grupos.
- Los grupos pertenecen a un grado y ciclo.
- Se pueden desactivar y reactivar sin eliminar sus inscripciones ni registros.
- Cada grupo debe tener una capacidad máxima obligatoria.
- La capacidad podrá modificarse, pero no reducirse por debajo de la cantidad de alumnos inscritos.
- Los cambios de nombre, capacidad y estado deben conservar historial.

**Pendientes físicos:**
- No existe todavía el campo `capacidad_maxima`.
- No existe todavía una tabla de historial de modificaciones de grupos.
- El campo `estado` no tiene una restricción CHECK que defina sus valores.

### 3.7 `alumnos`

**Propósito:** almacenar los datos básicos de identificación de los alumnos.

| Campo | Tipo SQL | Nulo | Predeterminado | Clave / restricción | Descripción |
|---|---|---|---|---|---|
| `id_alumno` | `INT` | No | `AUTO_INCREMENT` | PK | Identificador del alumno. |
| `matricula` | `VARCHAR(30)` | No | — | UNIQUE | Matrícula única, capturada manualmente. |
| `nombres` | `VARCHAR(100)` | No | — | — | Nombres del alumno. |
| `apellidos` | `VARCHAR(100)` | No | — | — | Apellidos del alumno. |
| `fecha_nacimiento` | `DATE` | Sí | `NULL` | — | Fecha de nacimiento opcional. |
| `estado` | `TINYINT(1)` | No | `1` | — | Estado del alumno. |
| `fecha_registro` | `DATETIME` | No | `CURRENT_TIMESTAMP` | — | Fecha y hora de registro. |

**Reglas funcionales aprobadas:**
- El director registra alumnos individualmente o mediante importación de plantilla Excel.
- La importación es parcial: los registros correctos se guardan y los incorrectos quedan identificados para corrección.
- La importación no actualiza alumnos existentes.
- La matrícula puede corregirse desde el formulario y debe conservar historial.
- Los datos personales modificados deben conservar historial.
- No se elimina físicamente a los alumnos.
- No se incorporará un campo `sexo`, porque no se considera necesario para el objetivo principal de registro de calificaciones.

**Estados funcionales aprobados:**

| Valor | Estado |
|---:|---|
| 1 | ACTIVO |
| 2 | BAJA_TEMPORAL |
| 3 | BAJA_DEFINITIVA |

**Observaciones técnicas:**
- El campo está definido actualmente como `TINYINT(1)`, pero no hay un CHECK que limite los valores a 1, 2 y 3.
- No existe todavía una tabla de historial de datos personales o de cambios de matrícula.
- No existe todavía una tabla de historial de movimientos del alumno.

### 3.8 `alumnos_grupos`

**Propósito:** registrar las inscripciones de alumnos en grupos y conservar sus movimientos entre grupos.

| Campo | Tipo SQL | Nulo | Predeterminado | Clave / restricción | Descripción |
|---|---|---|---|---|---|
| `id_alumno_grupo` | `INT` | No | `AUTO_INCREMENT` | PK | Identificador de la inscripción. |
| `id_alumno` | `INT` | No | — | FK | Alumno inscrito. |
| `id_grupo` | `INT` | No | — | FK | Grupo correspondiente. |
| `fecha_asignacion` | `DATE` | No | — | — | Fecha de inicio de la inscripción. |
| `fecha_retiro` | `DATE` | Sí | `NULL` | CHECK | Fecha de finalización de la inscripción. |
| `estado` | `TINYINT(1)` | No | `1` | — | Estado de la inscripción. |

**Restricciones físicas:**
- `fk_alumno_grupo_alumno`: referencia `alumnos.id_alumno`, `ON DELETE RESTRICT ON UPDATE CASCADE`.
- `fk_alumno_grupo_grupo`: referencia `grupos.id_grupo`, `ON DELETE RESTRICT ON UPDATE CASCADE`.
- `chk_fechas_alumno_grupo`: `fecha_retiro IS NULL OR fecha_retiro >= fecha_asignacion`.

**Reglas funcionales aprobadas:**
- Un alumno solo puede tener una inscripción activa a un grupo por ciclo escolar.
- Al cambiar de grupo, se finaliza la inscripción anterior y se crea una nueva; no se modifica la inscripción histórica.
- Una baja temporal o definitiva finaliza la inscripción vigente.
- Una reincorporación crea una nueva inscripción.
- Las calificaciones y asistencias anteriores no se transfieren al nuevo grupo.
- Los movimientos deben conservar fecha, responsable y motivo.

**Estados funcionales aprobados:**

| Valor | Estado |
|---:|---|
| 1 | ACTIVA |
| 0 | FINALIZADA |

**Observaciones técnicas:**
- No existe una restricción UNIQUE que garantice por sí sola una sola inscripción activa por alumno y ciclo escolar.
- La relación con el ciclo se obtiene a través de `grupos.id_ciclo`.
- Debe implementarse una validación transaccional para impedir inscripciones activas duplicadas.
- El historial de movimientos del alumno todavía no tiene una tabla física propia.

### 3.9 `asignaciones_docentes`

**Propósito:** registrar la asignación de profesores a grupos.

| Campo | Tipo SQL | Nulo | Predeterminado | Clave / restricción | Descripción |
|---|---|---|---|---|---|
| `id_asignacion` | `INT` | No | `AUTO_INCREMENT` | PK | Identificador de la asignación. |
| `id_profesor` | `INT` | No | — | FK | Profesor asignado. |
| `id_grupo` | `INT` | No | — | FK | Grupo asignado. |
| `fecha_asignacion` | `DATE` | No | — | CHECK | Inicio de la asignación. |
| `fecha_fin` | `DATE` | Sí | `NULL` | CHECK | Fin de la asignación. |
| `estado` | `TINYINT` | No | `2` | CHECK | Estado de la asignación. |

**Restricciones físicas:**
- `fk_asignacion_profesor`: referencia `profesores.id_profesor`, `ON DELETE RESTRICT ON UPDATE CASCADE`.
- `fk_asignacion_grupo`: referencia `grupos.id_grupo`, `ON DELETE RESTRICT ON UPDATE CASCADE`.
- `chk_estado_asignacion`: estado IN (1, 2, 3, 4).
- `chk_fechas_asignacion`: `fecha_fin IS NULL OR fecha_fin >= fecha_asignacion`.

**Estados funcionales aprobados:**

| Valor | Estado |
|---:|---|
| 1 | PROGRAMADA |
| 2 | ACTIVA |
| 3 | INACTIVA |
| 4 | CANCELADA |

**Reglas funcionales aprobadas:**
- Un profesor puede tener varios grupos y un grupo puede tener varios profesores.
- No se permite más de una asignación activa para la misma combinación profesor-grupo.
- El director asigna grupos a profesores.
- Las asignaciones programadas se activan automáticamente al llegar su fecha de inicio.
- Los cambios de profesor generan nuevas asignaciones y conservan las anteriores.
- Las asignaciones programadas pueden cancelarse antes de comenzar, conservando el registro de cancelación.
- No se debe desactivar a un profesor con asignaciones activas o programadas sin resolver.

**Observación técnica:** la estructura no tiene una restricción UNIQUE que impida asignaciones activas duplicadas ni implementa por sí sola la activación automática. Esas reglas requieren lógica de negocio y un mecanismo para gestionar las fechas.

### 3.10 `materias`

**Propósito:** mantener el catálogo compartido de materias.

| Campo | Tipo SQL | Nulo | Predeterminado | Clave / restricción | Descripción |
|---|---|---|---|---|---|
| `id_materia` | `INT` | No | `AUTO_INCREMENT` | PK | Identificador de la materia. |
| `nombre` | `VARCHAR(100)` | No | — | UNIQUE | Nombre de la materia. |
| `descripcion` | `VARCHAR(255)` | Sí | `NULL` | — | Descripción opcional. |
| `id_usuario_registro` | `INT` | No | — | FK | Usuario que registró la materia. |
| `estado` | `TINYINT` | No | `1` | CHECK | Estado de la materia. |

**Restricciones físicas:**
- `fk_materia_usuario`: referencia `usuarios.id_usuario`, `ON DELETE RESTRICT ON UPDATE CASCADE`.
- `uq_materia_nombre`: nombre único.
- `chk_estado_materia`: estado IN (0, 1).

**Estados funcionales aprobados:**

| Valor | Estado |
|---:|---|
| 0 | INACTIVA |
| 1 | ACTIVA |

**Reglas funcionales aprobadas:**
- El catálogo es compartido.
- Solo los profesores pueden crear materias; el director no las crea directamente desde el catálogo.
- Se identifica al usuario que registró cada materia.
- Solo el profesor creador puede desactivar su materia, si no está utilizada en una asignación activa.
- Las materias no se eliminan físicamente.
- Una materia puede utilizarse en distintos grupos.
- Se deben evitar duplicados de nombres, incluyendo diferencias de mayúsculas/minúsculas según la política de comparación definida para el catálogo.

**Observación:** la FK identifica al usuario creador, pero la regla de que sea un profesor y que solo él pueda desactivar la materia debe validarse en la lógica de negocio.

### 3.11 `materias_asignadas`

**Propósito:** relacionar las materias del catálogo con las asignaciones docentes y, por medio de estas, con un profesor y un grupo.

| Campo | Tipo SQL | Nulo | Predeterminado | Clave / restricción | Descripción |
|---|---|---|---|---|---|
| `id_materia_asignada` | `INT` | No | `AUTO_INCREMENT` | PK | Identificador de la asignación de materia. |
| `id_asignacion` | `INT` | No | — | FK | Asignación docente correspondiente. |
| `id_materia` | `INT` | No | — | FK | Materia del catálogo. |
| `fecha_asignacion` | `DATE` | No | — | CHECK | Inicio de la asignación de materia. |
| `fecha_fin` | `DATE` | Sí | `NULL` | CHECK | Fin de la asignación de materia. |
| `estado` | `TINYINT` | No | `2` | CHECK | Estado de la asignación. |

**Restricciones físicas:**
- `fk_materia_asignada_asignacion`: referencia `asignaciones_docentes.id_asignacion`, `ON DELETE RESTRICT ON UPDATE CASCADE`.
- `fk_materia_asignada_materia`: referencia `materias.id_materia`, `ON DELETE RESTRICT ON UPDATE CASCADE`.
- `chk_estado_materia_asignada`: estado IN (1, 2, 3, 4).
- `chk_fechas_materia`: `fecha_fin IS NULL OR fecha_fin >= fecha_asignacion`.

**Estados funcionales aprobados:**

| Valor | Estado |
|---:|---|
| 1 | PROGRAMADA |
| 2 | ACTIVA |
| 3 | INACTIVA |
| 4 | CANCELADA |

**Reglas funcionales aprobadas:**
- El profesor puede seleccionar las materias que impartirá dentro de sus grupos asignados.
- Una misma materia no puede repetirse dentro del mismo grupo mientras exista una asignación vigente, aunque se intente asignarla a otro profesor.
- La misma materia puede estar asignada en diferentes grupos.
- Cuando finaliza la asignación de una materia, otro profesor puede impartir esa misma materia en el mismo grupo posteriormente.
- Nunca deben existir dos asignaciones vigentes de la misma materia dentro del mismo grupo.
- Finalizar la asignación no desactiva la materia del catálogo.
- Los profesores conservan acceso de consulta a sus registros históricos de asignaciones finalizadas, pero no pueden realizar nuevas capturas ordinarias.
- Los registros académicos deben permanecer vinculados a la asignación original.

**Regla de integridad importante:** para validar la unicidad de materia por grupo, el sistema debe considerar `materias_asignadas` → `asignaciones_docentes` → `grupos`. La estructura actual no tiene una restricción que garantice esta regla por sí sola. Debe implementarse una validación transaccional y evaluarse protección adicional en MySQL.

## 4. Relaciones físicas entre las once tablas

Las siguientes relaciones están respaldadas por llaves foráneas del respaldo SQL:

| Tabla origen | Campo | Tabla destino | Campo destino |
|---|---|---|---|
| `profesores` | `id_usuario` | `usuarios` | `id_usuario` |
| `grados` | `id_nivel` | `niveles_educativos` | `id_nivel` |
| `grupos` | `id_grado` | `grados` | `id_grado` |
| `grupos` | `id_ciclo` | `ciclos_escolares` | `id_ciclo` |
| `alumnos_grupos` | `id_alumno` | `alumnos` | `id_alumno` |
| `alumnos_grupos` | `id_grupo` | `grupos` | `id_grupo` |
| `asignaciones_docentes` | `id_profesor` | `profesores` | `id_profesor` |
| `asignaciones_docentes` | `id_grupo` | `grupos` | `id_grupo` |
| `materias` | `id_usuario_registro` | `usuarios` | `id_usuario` |
| `materias_asignadas` | `id_asignacion` | `asignaciones_docentes` | `id_asignacion` |
| `materias_asignadas` | `id_materia` | `materias` | `id_materia` |

### Diagrama lógico simplificado

```text
usuarios
 ├── profesores
 │    └── asignaciones_docentes
 │         ├── grupos
 │         │    ├── grados
 │         │    │    └── niveles_educativos
 │         │    ├── ciclos_escolares
 │         │    └── alumnos_grupos
 │         │         └── alumnos
 │         └── materias_asignadas
 │              └── materias
 └── materias (usuario que registró la materia)
```

El diagrama es una representación simplificada de las relaciones físicas; no sustituye el esquema SQL.

## 5. Reglas que requieren lógica de negocio o protección adicional

| Regla | Situación en el esquema actual | Trabajo necesario |
|---|---|---|
| Un solo ciclo activo a la vez | No garantizado por UNIQUE/CHECK | Validación al activar un ciclo y protección contra concurrencia. |
| Capacidad máxima de grupo | Campo inexistente | Diseñar e incorporar `capacidad_maxima` con aprobación. |
| No reducir capacidad por debajo de inscritos | No implementado | Validación al modificar capacidad. |
| Una inscripción activa por alumno y ciclo | No garantizada por UNIQUE/CHECK | Validación considerando `grupos.id_ciclo`. |
| Una asignación activa por profesor y grupo | No garantizada por UNIQUE/CHECK | Validación transaccional. |
| Una materia vigente por grupo, sin importar profesor | No garantizada por UNIQUE/CHECK | Validación transaccional considerando las dos tablas de asignación. |
| Activación automática de asignaciones programadas | No implementada en el DDL | Diseñar mecanismo de activación y manejo de fechas. |
| Solo el creador desactiva su materia | No garantizado por FK/CHECK | Validación de usuario y permisos en servicio. |
| Estados de usuarios, niveles, ciclos y grupos | No tienen CHECK en el respaldo | Definir y validar valores permitidos. |
| Estados de alumnos | No hay CHECK para valores 1, 2 y 3 | Validar valores permitidos. |
| Estados de inscripción | No hay CHECK para valores 0 y 1 | Validar valores permitidos. |

## 6. Elementos funcionales pendientes de estructura física

Esta lista no ordena crear todas las tablas de inmediato. Son necesidades identificadas durante el diseño que deben revisarse, agruparse y aprobarse antes de generar SQL.

### 6.1 Historiales y administración
- Historial de cambios de matrícula y datos personales.
- Historial de movimientos de alumnos.
- Historial de modificaciones de grupos (nombre, capacidad y estado).
- Historiales adicionales de asignaciones, si se necesitan eventos que no estén representados por sus registros y estados actuales.

### 6.2 Evaluación y calificaciones

Entidades propuestas durante el diseño:
- Periodos escolares.
- Configuraciones de evaluación y sus versiones.
- Criterios de evaluación.
- Actividades.
- Calificaciones.
- Historial de modificaciones de calificaciones.

Reglas aprobadas relevantes:
- Cada materia, grupo y periodo tendrá su propia configuración.
- Las ponderaciones de criterios suman 100%.
- Las actividades de un criterio tienen el mismo peso y sus calificaciones se promedian.
- Una calificación pendiente se representa con `NULL`, no con cero.
- Los cambios de configuración conservan versiones y no recalculan retroactivamente actividades anteriores.
- El peso de cada versión se basa proporcionalmente en su tiempo de vigencia.
- Una versión sin resultados se conserva en el historial, pero no participa en el cálculo final; los pesos de las versiones con resultados se normalizan.
- Falta definir con precisión el conteo de días naturales o lectivos y qué se considera resultado válido cuando hay actividades pendientes.

### 6.3 Asistencia

Entidades propuestas:
- Asistencias.
- Detalle de asistencia.
- Historial de modificaciones de asistencia.

Estados funcionales:
- PRESENTE.
- AUSENTE.
- RETARDO.
- JUSTIFICADO.

El registro se realizará por materia asignada, grupo y fecha.

### 6.4 Solicitudes y notificaciones

Entidades propuestas:
- Solicitudes de corrección.
- Detalles de solicitudes.
- Extensiones de autorizaciones.
- Notificaciones internas.

Las solicitudes pueden contener varias calificaciones, revisadas individualmente. La autorización tiene un límite de tiempo y no reabre el periodo completo.

### 6.5 Seguridad

Se identificaron necesidades de:
- Historial de accesos.
- Bloqueos por intentos fallidos.
- Restablecimiento de contraseña temporal.
- Configuración de cierre automático de sesión.

La estructura física correspondiente aún debe revisarse y aprobarse.

## 7. Reglas de colaboración para el equipo

1. Este documento es la referencia común de estructura y reglas aprobadas.
2. Ningún integrante debe crear tablas, campos o relaciones por su cuenta.
3. Si un módulo necesita un dato o relación que no aparece aquí, debe solicitarse al responsable de arquitectura y base de datos.
4. No asumir que los elementos pendientes ya existen físicamente.
5. No ejecutar respaldos completos que contengan `DROP TABLE IF EXISTS` sobre la base de datos de trabajo.
6. Los scripts SQL oficiales deben conservarse en `database/`.
7. Las modificaciones de estructura deben documentarse, revisarse y compartirse mediante Git.
8. Los módulos deben utilizar las mismas entidades, nombres y reglas para evitar incompatibilidades.
9. Las validaciones de negocio deben centralizarse en la capa de servicios y protegerse con transacciones cuando involucren varias operaciones relacionadas.
10. Este diccionario debe actualizarse cuando una modificación de esquema sea aprobada y ejecutada.

## 8. Control de cambios

| Versión | Fecha | Descripción |
|---|---|---|
| 1.0 | 23/11/2026 | Integración inicial de las once tablas existentes y reglas funcionales revisadas en los cuatro bloques. |

**Fin del documento.**
