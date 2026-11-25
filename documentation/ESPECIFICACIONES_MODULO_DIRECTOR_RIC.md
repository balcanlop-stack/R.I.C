# R.I.C. — Especificaciones del módulo Director

**Versión:** 1.1 — Borrador actualizado para revisión  
**Fecha:** 25 de noviembre de 2026  
**Proyecto:** Registro Integral de Calificaciones  
**Responsable del módulo:** Integrante asignado al módulo Director  
**Referencias:** Documento de decisiones y especificaciones funcionales R.I.C. (versión 1.1), Diccionario de Datos R.I.C. y especificaciones de los demás módulos.

---

## 1. Propósito del módulo

El módulo Director permite administrar la información escolar necesaria para operar R.I.C., principalmente alumnos, grupos, profesores, asignaciones docentes, ciclos y periodos. También permite consultar información académica e histórica y proporcionar las pantallas y acciones para que el Director revise y decida sobre solicitudes de corrección de calificaciones.

R.I.C. debe mantenerse enfocado en el registro y consulta de calificaciones. No se deben incorporar funciones administrativas escolares que no estén contempladas en las decisiones aprobadas.

## 2. Responsabilidades del Director

El usuario con rol `DIRECTOR` puede:

- Administrar alumnos y sus inscripciones a grupos.
- Crear y administrar grupos.
- Registrar profesores y proporcionar credenciales iniciales.
- Asignar grupos a profesores y gestionar sustituciones.
- Administrar ciclos escolares y configurar/cerrar periodos.
- Consultar información académica e histórica.
- Revisar y decidir la aprobación o el rechazo de solicitudes de corrección y extensiones.
- Consultar reportes.
- Administrar el estado de las cuentas de profesores.

Los alumnos no tienen cuentas ni acceso al sistema. El rol `DIRECTOR` se almacena en `usuarios.rol`; no existe una tabla independiente de directores.

### 2.1 Límites de responsabilidad entre módulos

El flujo de solicitudes se divide entre módulos para evitar duplicar reglas o modificar una calificación desde más de un lugar:

- **Solicitudes y Reportes:** administra el flujo de solicitudes, autorizaciones, extensiones, vencimientos, estados e historial.
- **Director:** proporciona las pantallas y acciones para revisar cada solicitud o detalle y decidir su aprobación o rechazo, así como resolver solicitudes de extensión.
- **Profesor:** crea solicitudes, consulta su estado y captura la corrección cuando haya sido autorizada y esté dentro del plazo.
- **Calificaciones:** ejecuta la modificación autorizada y conserva el historial de calificaciones.

El módulo Director no debe implementar por su cuenta la lógica completa del flujo ni modificar directamente registros de calificaciones. Debe utilizar los servicios y contratos definidos para integrarse con el módulo Solicitudes y Reportes.

## 3. Administración de alumnos

### 3.1 Registro y consulta

El Director debe poder registrar alumnos individualmente y consultar los alumnos registrados.

Los campos físicos actuales de `alumnos` son:

| Campo | Uso |
|---|---|
| `id_alumno` | Identificador interno. |
| `matricula` | Matrícula única, capturada manualmente. |
| `nombres` | Nombres del alumno. |
| `apellidos` | Apellidos del alumno. |
| `fecha_nacimiento` | Fecha de nacimiento opcional. |
| `estado` | Estado del alumno. |
| `fecha_registro` | Fecha y hora de registro. |

No agregar el campo `sexo`: se decidió que no es necesario para el objetivo principal del proyecto. Tampoco se contemplan CURP, domicilio, teléfonos ni datos de tutores.

### 3.2 Matrícula y modificaciones

- La matrícula debe ser única.
- El Director puede corregir una matrícula.
- Las modificaciones de matrícula y datos personales deben conservar un historial con valor anterior, valor nuevo, motivo, fecha y responsable.
- No actualizar alumnos existentes mediante la importación masiva; las modificaciones se realizan desde el formulario.

**Pendiente de base de datos:** el esquema físico confirmado no incluye una tabla de historial para estos cambios. No crearla desde el módulo sin aprobación del responsable de arquitectura y base de datos.

### 3.3 Importación masiva

Se permitirá importar alumnos mediante una plantilla oficial de Excel.

La importación es parcial:

- Los registros válidos pueden guardarse.
- Los registros incorrectos deben identificarse para corregirlos.
- Un registro incorrecto no debe impedir que se procesen los demás registros válidos.
- La importación no actualiza alumnos que ya existen.

El formato definitivo de la plantilla y los detalles de validación deben coordinarse con el responsable del proyecto.

### 3.4 Estados y bajas

Estados funcionales aprobados para `alumnos.estado`:

| Valor | Estado |
|---:|---|
| 1 | ACTIVO |
| 2 | BAJA_TEMPORAL |
| 3 | BAJA_DEFINITIVA |

No eliminar alumnos físicamente.

**Baja temporal:**
- Finalizar la inscripción vigente.
- Conservar calificaciones y asistencias.
- Permitir una reincorporación posterior.
- La reincorporación crea una nueva inscripción; no reactiva la inscripción anterior.
- El alumno continúa su evaluación desde la fecha de reincorporación, conforme a las reglas de la nueva inscripción descritas en la sección 3.5.

**Baja definitiva:**
- Finalizar la inscripción vigente.
- Conservar el historial académico.
- No permitir reincorporación ordinaria.
- El Director puede revertir la baja mediante un procedimiento especial, registrando motivo y conservando el movimiento original.
- Después de la reversión, el alumno vuelve a estado ACTIVO, pero requiere una nueva inscripción; no se reactiva la inscripción anterior.

**Pendiente técnico:** el campo `estado` existe como `TINYINT(1)`, pero el esquema confirmado no incluye una restricción `CHECK` para los valores 1, 2 y 3.

### 3.5 Inscripciones y cambios de grupo

La tabla física `alumnos_grupos` contiene:

- `id_alumno_grupo`
- `id_alumno`
- `id_grupo`
- `fecha_asignacion`
- `fecha_retiro`
- `estado`

Estados funcionales aprobados para `alumnos_grupos.estado`:

| Valor | Estado |
|---:|---|
| 1 | ACTIVA |
| 0 | FINALIZADA |

Reglas generales:

- Un alumno solo puede tener una inscripción activa a un grupo por ciclo escolar.
- Al cambiar de grupo, finalizar la inscripción anterior y crear una nueva.
- No modificar la inscripción histórica para representar el nuevo grupo.
- Cada movimiento debe conservar fecha, motivo y responsable.
- Una baja temporal o definitiva finaliza la inscripción vigente.
- Una reincorporación crea una nueva inscripción.

**Cambio de grupo durante un periodo:**

- Las calificaciones y asistencias anteriores permanecen asociadas a la inscripción original.
- No se transfieren al nuevo grupo.
- La nueva inscripción utiliza la configuración de evaluación vigente del grupo destino desde la fecha de incorporación.
- El cálculo de la nueva inscripción considera únicamente las actividades que correspondan a esa inscripción.
- Las actividades realizadas antes de la incorporación no se consideran automáticamente para la nueva inscripción.
- Si se requiere recuperar evidencia de actividades que el alumno no pudo realizar, el profesor podrá asignar actividades de recuperación conforme a las reglas del módulo de Calificaciones. La recuperación debe corresponder a un criterio del grupo destino y no debe alterar la ponderación del criterio.
- Si no existe una correspondencia clara entre la actividad pendiente y un criterio del grupo destino, el profesor debe resolver esa correspondencia antes de asignar la recuperación.

**Reincorporación después de baja temporal:**

- Se crea una nueva inscripción en `alumnos_grupos`; la inscripción anterior permanece finalizada.
- Las calificaciones y asistencias anteriores se conservan vinculadas a la inscripción original y no se transfieren.
- El alumno continúa su evaluación desde la fecha de reincorporación.
- Si vuelve al mismo grupo y al mismo periodo, puede utilizar la configuración vigente del grupo, siempre que esta no haya sido sustituida por una nueva versión.
- Las actividades anteriores no se asignan automáticamente; cuando corresponda, el profesor podrá establecer recuperaciones conforme a las reglas del módulo de Calificaciones.
- La reincorporación no genera por sí misma una nueva versión de la configuración de evaluación.

La relación con el ciclo escolar se obtiene mediante `alumnos_grupos.id_grupo` → `grupos.id_grupo` → `grupos.id_ciclo`.

**Regla de diseño para calificaciones:** todos los alumnos inscritos en un grupo cursan todas las materias asignadas a ese grupo. No se administrarán inscripciones individuales por materia. Las futuras calificaciones deberán conservar el contexto de la inscripción del alumno y de la actividad evaluada; no deben relacionarse únicamente mediante `id_alumno`. La validación deberá asegurar que el alumno y la materia correspondan al mismo grupo. Esta regla no autoriza crear por cuenta propia tablas o relaciones físicas nuevas.

**Pendiente técnico:** el esquema actual no garantiza por sí solo una sola inscripción activa por alumno y ciclo. Se necesita validación transaccional en la lógica de negocio y revisar protección adicional en la base de datos.

### 3.6 Historial y promoción

El historial de movimientos debe contemplar:

- Alta.
- Cambio de grupo.
- Promoción.
- Baja temporal.
- Reincorporación.
- Baja definitiva.
- Reversión de baja definitiva.

Al finalizar un ciclo:

- El sistema podrá generar propuestas de promoción.
- El Director decide individualmente el grado y grupo de cada alumno.
- Puede promoverlo, mantenerlo en el mismo grado o cambiarlo de nivel.
- Los alumnos que terminan el último grado quedan pendientes de decisión del Director.
- El egreso debe ser una acción explícita.

**Pendiente de base de datos:** el esquema físico confirmado no contiene una tabla propia para el historial de movimientos ni una estructura de promoción/egreso. Solicitar su diseño antes de implementarla.

## 4. Administración de grupos

La tabla física `grupos` contiene:

- `id_grupo`
- `id_grado`
- `id_ciclo`
- `nombre`
- `estado`

El Director es responsable de crear y administrar grupos.

Reglas:

- Cada grupo pertenece a un grado y a un ciclo escolar.
- Los grupos se crean para cada ciclo.
- El Director puede modificar el nombre y estado.
- Los grupos pueden desactivarse y reactivarse.
- La desactivación no elimina inscripciones ni registros históricos.
- No eliminar físicamente grupos relacionados con información histórica.

### 4.1 Capacidad máxima

Cada grupo debe tener una capacidad máxima obligatoria:

- Debe ser un entero mayor que cero.
- No se puede superar al inscribir alumnos.
- No se puede reducir por debajo de la cantidad de alumnos inscritos.
- El Director puede modificarla.
- Cada modificación debe conservar valor anterior, valor nuevo, fecha, responsable y motivo.

**Pendiente de base de datos:** `grupos` todavía no contiene `capacidad_maxima` ni una tabla de historial de cambios. No agregar el campo ni crear la tabla desde el módulo sin autorización del responsable de arquitectura y base de datos.

## 5. Administración de profesores

La estructura actual utiliza:

- `usuarios`: cuenta, correo, hash de contraseña, rol y estado.
- `profesores`: perfil docente asociado mediante `id_usuario`.

Reglas:

- El Director crea los perfiles docentes.
- El Director proporciona las credenciales iniciales.
- El profesor puede cambiar su contraseña.
- Si un profesor deja la institución, el Director desactiva su usuario.
- No eliminar físicamente profesores ni sus registros.
- No desactivar un profesor que tenga asignaciones activas o programadas sin resolver; primero deben atenderse esas asignaciones.

El número de empleado es opcional en la estructura actual.

## 6. Asignación de grupos a profesores y sustituciones

La tabla física `asignaciones_docentes` relaciona `profesores` con `grupos`.

Campos actuales:

- `id_asignacion`
- `id_profesor`
- `id_grupo`
- `fecha_asignacion`
- `fecha_fin`
- `estado`

Estados funcionales:

| Valor | Estado |
|---:|---|
| 1 | PROGRAMADA |
| 2 | ACTIVA |
| 3 | INACTIVA |
| 4 | CANCELADA |

Reglas:

- Un profesor puede tener varios grupos.
- Un grupo puede tener varios profesores.
- No permitir más de una asignación activa para la misma combinación profesor-grupo.
- Las asignaciones programadas se activan automáticamente al llegar su fecha de inicio.
- Un cambio programado puede cancelarse antes de comenzar, conservando el registro de cancelación.
- La finalización anticipada debe registrar motivo e historial.
- El profesor conserva consulta de sus registros históricos de asignaciones finalizadas, sin nuevas capturas ordinarias.

**Sustitución de profesor:**

- Para sustituir a un profesor, se finaliza su asignación anterior y se crea una nueva asignación para el profesor sustituto.
- No se debe reutilizar ni modificar la asignación anterior para representar al sustituto.
- Las actividades y calificaciones registradas anteriormente permanecen vinculadas al profesor y a la asignación con los que fueron creadas, conservando su autoría e historial.
- El nuevo profesor puede consultar la información académica necesaria del grupo y de la materia, y puede crear nuevas actividades y calificaciones durante su propia asignación.
- La sustitución de profesor no genera por sí misma una nueva versión de la configuración de evaluación.

**Continuidad de la configuración de evaluación:**

- La configuración pertenece a la combinación de materia, grupo y periodo; no pertenece exclusivamente al profesor o a la asignación docente.
- Cuando cambia el profesor, el sustituto continúa utilizando la configuración vigente de esa materia, grupo y periodo.
- Las nuevas actividades deben identificar al profesor y a la asignación que las creó.
- Solo un cambio real en los criterios o ponderaciones genera una nueva versión de configuración, conforme a la opción de versionado aprobada para el módulo de Calificaciones.

**Pendiente técnico:** el DDL actual no garantiza por sí solo la unicidad de asignaciones activas ni activa automáticamente las asignaciones programadas. Coordinar la validación transaccional y el mecanismo de activación con arquitectura.

## 7. Ciclos y periodos escolares

El Director administra los ciclos escolares. La tabla `ciclos_escolares` existe y contiene nombre, fechas de inicio y fin y estado.

Reglas:

- Solamente puede existir un ciclo escolar activo a la vez.
- Conservar ciclos y registros históricos.
- El Director configura los periodos: cantidad, nombre, fechas de inicio y fin y fecha límite de captura.
- El Director puede cerrar manualmente un periodo.
- La fecha límite bloquea modificaciones ordinarias aunque el periodo no se haya cerrado formalmente.
- Después del cierre, las correcciones se realizan mediante solicitudes autorizadas, sin reabrir todo el periodo.

**Pendiente de base de datos:** la tabla `periodos` todavía no aparece entre las tablas físicas confirmadas. El diseño de sus campos y relaciones debe aprobarse antes de crearla.

**Pendiente técnico:** la estructura actual no garantiza por sí sola que solo exista un ciclo activo.

## 8. Consulta académica, reportes y solicitudes

### 8.1 Consulta académica

El Director puede consultar información académica e histórica. El alcance de cada reporte debe limitarse a información pertinente para R.I.C. y coordinarse con los módulos de Calificaciones y Solicitudes y Reportes.

La consulta histórica debe respetar la inscripción, asignación docente y configuración a las que pertenecen los registros. Por ejemplo, un cambio de grupo o una sustitución docente no debe hacer que los registros anteriores aparezcan como si pertenecieran a la nueva inscripción o al nuevo profesor.

### 8.2 Revisión y decisión de solicitudes de corrección

Cuando termina el plazo ordinario de captura, el profesor necesita autorización del Director para corregir calificaciones.

Desde las pantallas del módulo Director, el Director puede:

- Consultar las solicitudes recibidas.
- Revisar los detalles y la explicación del profesor.
- Aprobar o rechazar individualmente cada calificación incluida.
- Establecer el límite de tiempo para realizar una corrección autorizada.
- Revisar solicitudes de extensión y aprobarlas o rechazarlas.

Una solicitud puede contener varias calificaciones y cada detalle se revisa individualmente. El profesor explica el error, pero no propone el nuevo valor. Si se autoriza, el profesor captura el nuevo valor dentro del plazo.

Los estados funcionales de cada detalle son:

- `PENDIENTE`
- `APROBADA`
- `RECHAZADA`
- `COMPLETADA`
- `VENCIDA`

Las solicitudes pendientes se conservan aunque el profesor termine su asignación. El Director puede decidir sobre una corrección específica pendiente sin reactivar la asignación docente.

El módulo Director se encarga de la decisión del Director; el módulo Solicitudes y Reportes administra el flujo, estados, extensiones, vencimientos e historial; el módulo Calificaciones ejecuta la modificación autorizada y conserva el historial. El módulo Director no debe modificar directamente la calificación.

**Pendiente de base de datos:** las tablas de solicitudes, detalles y extensiones todavía no aparecen entre las tablas físicas confirmadas. Deben diseñarse con el responsable de arquitectura antes de implementarlas.

### 8.3 Notificaciones

Las notificaciones son internas; no se utilizará correo externo.

El Director debe recibir notificaciones de:

- Nueva solicitud de corrección.
- Nueva solicitud de extensión.

Si una notificación recibe nueva información, debe volver a marcarse como no leída.

**Pendiente de base de datos:** la estructura de notificaciones todavía no aparece entre las tablas físicas confirmadas.

## 9. Límites del módulo Director

El responsable del módulo Director no debe:

- Crear o modificar tablas, columnas, índices o relaciones sin autorización.
- Crear una tabla independiente para directores.
- Crear materias desde el catálogo: esa función corresponde a profesores.
- Eliminar físicamente alumnos, profesores, grupos o registros históricos.
- Implementar funcionalidades administrativas escolares fuera del alcance acordado.
- Duplicar conexiones JDBC, configuración general o componentes compartidos del proyecto.
- Asumir que las entidades propuestas o pendientes ya existen físicamente.
- Implementar de forma duplicada la gestión del flujo de solicitudes que corresponde al módulo Solicitudes y Reportes.
- Modificar directamente calificaciones para resolver solicitudes; esa operación corresponde al módulo de Calificaciones mediante el flujo autorizado.
- Crear una nueva configuración de evaluación únicamente porque cambió el profesor o porque un alumno cambió de grupo o se reincorporó.

Si se necesita un campo, relación, tabla o regla adicional, documentar la necesidad y solicitar revisión al responsable de arquitectura y base de datos.

## 10. Integración técnica

El proyecto utiliza Java, JavaFX, Maven, MySQL y JDBC, con arquitectura MVC + DAO + Service.

El módulo debe:

- Respetar los paquetes y convenciones existentes del proyecto.
- Separar controladores, modelos, DAO y servicios.
- Utilizar la conexión JDBC centralizada.
- No incorporar una conexión independiente a MySQL.
- No crear FXML/CSS compartidos ni alterar interfaces comunes sin coordinación con el responsable de integración.
- Mantener los nombres de tablas y campos del diccionario de datos.
- Usar transacciones cuando una operación implique varios cambios relacionados, por ejemplo finalizar una inscripción y crear otra, o finalizar una asignación y registrar su sustitución.
- Manejar errores de validación y de base de datos sin dejar operaciones parcialmente aplicadas.
- Integrarse con los servicios de los otros módulos mediante responsabilidades y contratos acordados, evitando duplicar reglas de negocio.

La estructura y los archivos comunes del proyecto deben revisarse con el responsable de integración antes de agregar nuevas clases o recursos.

## 11. Entregables esperados

El integrante responsable debe entregar:

1. Funcionalidades del módulo Director acordadas y probadas.
2. Clases Java organizadas conforme a MVC + DAO + Service.
3. Consultas y operaciones DAO compatibles con las tablas físicas existentes y autorizadas.
4. Validaciones de negocio correspondientes.
5. Integración de las pantallas de revisión y decisión de solicitudes con el módulo Solicitudes y Reportes.
6. Lista de campos, tablas o relaciones que considere necesarios y que aún no existan, sin crearlos por su cuenta.
7. Instrucciones breves para ejecutar y probar su módulo.
8. Cambios listos para revisión e integración mediante Git.

## 12. Estado de implementación

Este documento describe el alcance funcional y técnico del módulo; no afirma que las funcionalidades estén implementadas.

La estructura física confirmada se limita a las once tablas documentadas en el Diccionario de Datos R.I.C.:

1. `usuarios`
2. `profesores`
3. `niveles_educativos`
4. `ciclos_escolares`
5. `grados`
6. `grupos`
7. `alumnos`
8. `alumnos_grupos`
9. `asignaciones_docentes`
10. `materias`
11. `materias_asignadas`

Las tablas de periodos, evaluación, asistencias, solicitudes, notificaciones e historiales mencionadas como pendientes o propuestas no deben considerarse existentes físicamente hasta que el responsable de arquitectura y base de datos confirme su incorporación.

---

**Fin del documento.**
