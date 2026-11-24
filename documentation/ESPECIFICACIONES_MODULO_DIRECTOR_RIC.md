# R.I.C. --- Especificaciones del módulo Director

**Versión:** 1.0 --- Borrador para revisión\
**Proyecto:** Registro Integral de Calificaciones\
**Responsable del módulo:** Integrante asignado al módulo Director\
**Referencia:** Documento de decisiones y especificaciones funcionales
R.I.C. y Diccionario de Datos R.I.C.

------------------------------------------------------------------------

## 1. Propósito del módulo

El módulo Director permite administrar la información escolar necesaria
para operar R.I.C., principalmente alumnos, grupos, profesores,
asignaciones, ciclos y periodos. También permite consultar información
académica, revisar reportes y atender solicitudes de corrección de
calificaciones.

R.I.C. debe mantenerse enfocado en el registro y consulta de
calificaciones. No se deben incorporar funciones administrativas
escolares que no estén contempladas en las decisiones aprobadas.

## 2. Responsabilidades del Director

El usuario con rol `DIRECTOR` puede:

-   Administrar alumnos.
-   Crear y administrar grupos.
-   Registrar profesores y proporcionar credenciales iniciales.
-   Asignar grupos a profesores.
-   Administrar ciclos escolares y configurar periodos.
-   Consultar información académica e histórica.
-   Autorizar o rechazar solicitudes de corrección.
-   Consultar reportes.
-   Administrar el estado de las cuentas de profesores.

Los alumnos no tienen cuentas ni acceso al sistema. El rol `DIRECTOR` se
almacena en `usuarios.rol`; no existe una tabla independiente de
directores.

## 3. Administración de alumnos

### 3.1 Registro y consulta

El Director debe poder registrar alumnos individualmente y consultar los
alumnos registrados.

Los campos físicos actuales de `alumnos` son:

  Campo                Uso
  -------------------- -----------------------------------------
  `id_alumno`          Identificador interno.
  `matricula`          Matrícula única, capturada manualmente.
  `nombres`            Nombres del alumno.
  `apellidos`          Apellidos del alumno.
  `fecha_nacimiento`   Fecha de nacimiento opcional.
  `estado`             Estado del alumno.
  `fecha_registro`     Fecha y hora de registro.

No agregar el campo `sexo`: se decidió que no es necesario para el
objetivo principal del proyecto. Tampoco se contemplan CURP, domicilio,
teléfonos ni datos de tutores.

### 3.2 Matrícula y modificaciones

-   La matrícula debe ser única.
-   El Director puede corregir una matrícula.
-   Las modificaciones de matrícula y datos personales deben conservar
    un historial con valor anterior, valor nuevo, motivo, fecha y
    responsable.
-   No actualizar alumnos existentes mediante la importación masiva; las
    modificaciones se realizan desde el formulario.

**Pendiente de base de datos:** el respaldo actual no incluye una tabla
de historial para estos cambios. No crearla desde el módulo sin
aprobación del responsable de arquitectura y base de datos.

### 3.3 Importación masiva

Se permitirá importar alumnos mediante una plantilla oficial de Excel.

La importación es parcial: - Los registros válidos pueden guardarse. -
Los registros incorrectos deben identificarse para corregirlos. - Un
registro incorrecto no debe impedir que se procesen los demás registros
válidos. - La importación no actualiza alumnos que ya existen.

El formato definitivo de la plantilla y los detalles de validación deben
coordinarse con el responsable del proyecto.

### 3.4 Estados y bajas

Estados funcionales aprobados para `alumnos.estado`:

    Valor Estado
  ------- -----------------
        1 ACTIVO
        2 BAJA_TEMPORAL
        3 BAJA_DEFINITIVA

No eliminar alumnos físicamente.

**Baja temporal:** - Finalizar la inscripción vigente. - Conservar
calificaciones y asistencias. - Permitir una reincorporación
posterior. - La reincorporación crea una nueva inscripción. - El
Director decide si el alumno continúa en el mismo ciclo/periodo o
comienza en un nuevo ciclo, de acuerdo con las reglas funcionales
acordadas.

**Baja definitiva:** - Finalizar la inscripción vigente. - Conservar el
historial académico. - No permitir reincorporación ordinaria. - El
Director puede revertir la baja mediante un procedimiento especial,
registrando motivo y conservando el movimiento original. - Después de la
reversión, el alumno vuelve a estado ACTIVO, pero requiere una nueva
inscripción; no se reactiva la inscripción anterior.

**Pendiente técnico:** el campo `estado` existe como `TINYINT(1)`, pero
el respaldo no incluye una restricción `CHECK` para los valores 1, 2 y
3.

### 3.5 Inscripciones y cambios de grupo

La tabla física `alumnos_grupos` contiene:

-   `id_alumno_grupo`
-   `id_alumno`
-   `id_grupo`
-   `fecha_asignacion`
-   `fecha_retiro`
-   `estado`

Estados funcionales aprobados para `alumnos_grupos.estado`:

    Valor Estado
  ------- ------------
        1 ACTIVA
        0 FINALIZADA

Reglas: - Un alumno solo puede tener una inscripción activa a un grupo
por ciclo escolar. - Al cambiar de grupo, finalizar la inscripción
anterior y crear una nueva. - No modificar la inscripción histórica para
representar el nuevo grupo. - Las calificaciones y asistencias
anteriores no se transfieren al nuevo grupo. - Cada movimiento debe
conservar fecha, motivo y responsable. - Una baja temporal o definitiva
finaliza la inscripción vigente. - Una reincorporación crea una nueva
inscripción.

La relación con el ciclo escolar se obtiene mediante
`alumnos_grupos.id_grupo` → `grupos.id_grupo` → `grupos.id_ciclo`.

**Pendiente técnico:** el esquema actual no garantiza por sí solo una
sola inscripción activa por alumno y ciclo. Se necesita validación
transaccional en la lógica de negocio y revisar protección adicional en
la base de datos.

### 3.6 Historial y promoción

El historial de movimientos debe contemplar: - Alta. - Cambio de
grupo. - Promoción. - Baja temporal. - Reincorporación. - Baja
definitiva. - Reversión de baja definitiva.

Al finalizar un ciclo: - El sistema podrá generar propuestas de
promoción. - El Director decide individualmente el grado y grupo de cada
alumno. - Puede promoverlo, mantenerlo en el mismo grado o cambiarlo de
nivel. - Los alumnos que terminan el último grado quedan pendientes de
decisión del Director. - El egreso debe ser una acción explícita.

**Pendiente de base de datos:** el respaldo actual no contiene una tabla
propia para el historial de movimientos ni una estructura de
promoción/egreso. Solicitar su diseño antes de implementarla.

## 4. Administración de grupos

La tabla física `grupos` contiene:

-   `id_grupo`
-   `id_grado`
-   `id_ciclo`
-   `nombre`
-   `estado`

El Director es responsable de crear y administrar grupos.

Reglas: - Cada grupo pertenece a un grado y a un ciclo escolar. - Los
grupos se crean para cada ciclo. - El Director puede modificar el nombre
y estado. - Los grupos pueden desactivarse y reactivarse. - La
desactivación no elimina inscripciones ni registros históricos. - No
eliminar físicamente grupos relacionados con información histórica.

### 4.1 Capacidad máxima

Cada grupo debe tener una capacidad máxima obligatoria: - Debe ser un
entero mayor que cero. - No se puede superar al inscribir alumnos. - No
se puede reducir por debajo de la cantidad de alumnos inscritos. - El
Director puede modificarla. - Cada modificación debe conservar valor
anterior, valor nuevo, fecha, responsable y motivo.

**Pendiente de base de datos:** `grupos` todavía no contiene
`capacidad_maxima` ni una tabla de historial de cambios. No agregar el
campo ni crear la tabla desde el módulo sin autorización del responsable
de arquitectura y base de datos.

## 5. Administración de profesores

La estructura actual utiliza: - `usuarios`: cuenta, correo, hash de
contraseña, rol y estado. - `profesores`: perfil docente asociado
mediante `id_usuario`.

Reglas: - El Director crea los perfiles docentes. - El Director
proporciona las credenciales iniciales. - El profesor puede cambiar su
contraseña. - Si un profesor deja la institución, el Director desactiva
su usuario. - No eliminar físicamente profesores ni sus registros. - No
desactivar un profesor que tenga asignaciones activas o programadas sin
resolver; primero deben atenderse esas asignaciones.

El número de empleado es opcional en la estructura actual.

## 6. Asignación de grupos a profesores

La tabla física `asignaciones_docentes` relaciona `profesores` con
`grupos`.

Campos actuales: - `id_asignacion` - `id_profesor` - `id_grupo` -
`fecha_asignacion` - `fecha_fin` - `estado`

Estados funcionales:

    Valor Estado
  ------- ------------
        1 PROGRAMADA
        2 ACTIVA
        3 INACTIVA
        4 CANCELADA

Reglas: - Un profesor puede tener varios grupos. - Un grupo puede tener
varios profesores. - No permitir más de una asignación activa para la
misma combinación profesor-grupo. - Los cambios de profesor generan
nuevas asignaciones; conservar las anteriores. - Las asignaciones
programadas se activan automáticamente al llegar su fecha de inicio. -
Un cambio programado puede cancelarse antes de comenzar, conservando el
registro de cancelación. - La finalización anticipada debe registrar
motivo e historial. - El profesor conserva consulta de sus registros
históricos de asignaciones finalizadas, sin nuevas capturas ordinarias.

**Pendiente técnico:** el DDL actual no garantiza por sí solo la
unicidad de asignaciones activas ni activa automáticamente las
asignaciones programadas. Coordinar la validación transaccional y el
mecanismo de activación con arquitectura.

## 7. Ciclos y periodos escolares

El Director administra los ciclos escolares. La tabla `ciclos_escolares`
existe y contiene nombre, fechas de inicio y fin y estado.

Reglas: - Solamente puede existir un ciclo escolar activo a la vez. -
Conservar ciclos y registros históricos. - El Director configura los
periodos: cantidad, nombre, fechas de inicio y fin y fecha límite de
captura. - El Director puede cerrar manualmente un periodo. - La fecha
límite bloquea modificaciones ordinarias aunque el periodo no se haya
cerrado formalmente. - Después del cierre, las correcciones se realizan
mediante solicitudes autorizadas, sin reabrir todo el periodo.

**Pendiente de base de datos:** la tabla `periodos` todavía no aparece
en el respaldo. El diseño de sus campos y relaciones debe aprobarse
antes de crearla.

**Pendiente técnico:** la estructura actual no garantiza por sí sola que
solo exista un ciclo activo.

## 8. Consulta académica, reportes y solicitudes

### 8.1 Consulta académica

El Director puede consultar información académica e histórica. El
alcance de cada reporte debe limitarse a información pertinente para
R.I.C. y coordinarse con los módulos de calificaciones y solicitudes.

### 8.2 Solicitudes de corrección

Cuando termina el plazo ordinario de captura, el profesor necesita
autorización del Director para corregir calificaciones.

El Director puede: - Revisar solicitudes. - Aprobar o rechazar cada
calificación incluida. - Establecer un límite de tiempo para realizar la
corrección. - Revisar solicitudes de extensión y aprobarlas o
rechazarlas.

Una solicitud puede contener varias calificaciones y cada detalle se
revisa individualmente. El profesor explica el error, pero no propone el
nuevo valor. Si se autoriza, el profesor captura el nuevo valor dentro
del plazo.

Estados de detalle: - PENDIENTE. - APROBADA. - RECHAZADA. -
COMPLETADA. - VENCIDA.

Las solicitudes pendientes se conservan aunque el profesor termine su
asignación.

**Pendiente de base de datos:** las tablas de solicitudes, detalles y
extensiones todavía no aparecen en el respaldo. Deben diseñarse con el
responsable de arquitectura antes de implementarlas.

### 8.3 Notificaciones

Las notificaciones son internas; no se utilizará correo externo.

El Director debe recibir notificaciones de: - Nueva solicitud de
corrección. - Nueva solicitud de extensión.

Si una notificación recibe nueva información, debe volver a marcarse
como no leída.

**Pendiente de base de datos:** la estructura de notificaciones todavía
no aparece en el respaldo.

## 9. Límites del módulo Director

El responsable del módulo Director no debe: - Crear o modificar tablas,
columnas, índices o relaciones sin autorización. - Crear una tabla
independiente para directores. - Crear materias desde el catálogo: esa
función corresponde a profesores. - Eliminar físicamente alumnos,
profesores, grupos o registros históricos. - Implementar funcionalidades
administrativas escolares fuera del alcance acordado. - Duplicar
conexiones JDBC, configuración general o componentes compartidos del
proyecto. - Asumir que las entidades propuestas o pendientes ya existen
físicamente.

Si se necesita un campo, relación, tabla o regla adicional, documentar
la necesidad y solicitar revisión al responsable de arquitectura y base
de datos.

## 10. Integración técnica

El proyecto utiliza Java, JavaFX, Maven, MySQL y JDBC, con arquitectura
MVC + DAO + Service.

El módulo debe: - Respetar los paquetes y convenciones existentes del
proyecto. - Separar controladores, modelos, DAO y servicios. - Utilizar
la conexión JDBC centralizada. - No incorporar una conexión
independiente a MySQL. - No crear FXML/CSS compartidos ni alterar
interfaces comunes sin coordinación con el responsable de integración. -
Mantener los nombres de tablas y campos del diccionario de datos. - Usar
transacciones cuando una operación implique varios cambios relacionados,
por ejemplo finalizar una inscripción y crear otra. - Manejar errores de
validación y de base de datos sin dejar operaciones parcialmente
aplicadas.

La estructura y los archivos comunes del proyecto deben revisarse con el
responsable de integración antes de agregar nuevas clases o recursos.

## 11. Entregables esperados

El integrante responsable debe entregar: 1. Funcionalidades del módulo
Director acordadas y probadas. 2. Clases Java organizadas conforme a
MVC + DAO + Service. 3. Consultas y operaciones DAO compatibles con las
once tablas existentes. 4. Validaciones de negocio correspondientes. 5.
Lista de campos, tablas o relaciones que considere necesarios y que aún
no existan, sin crearlos por su cuenta. 6. Instrucciones breves para
ejecutar y probar su módulo. 7. Cambios listos para revisión e
integración mediante Git.

## 12. Estado de implementación

Este documento describe el alcance funcional y técnico del módulo; no
afirma que las funcionalidades estén implementadas. La estructura física
confirmada se limita a las once tablas documentadas en el diccionario de
datos.

**Fin del documento.**
