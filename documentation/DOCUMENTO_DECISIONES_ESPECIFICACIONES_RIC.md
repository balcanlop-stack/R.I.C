# R.I.C. — Registro Integral de Calificaciones
## Documento de decisiones y especificaciones funcionales

**Versión:** 1.1  
**Estado:** Documento de referencia actualizado  
**Fecha de actualización:** 24 de noviembre de 2026  
**Objetivo:** Compartir con los integrantes del equipo las decisiones funcionales, reglas de negocio y consideraciones técnicas acordadas para desarrollar los módulos del sistema R.I.C.

> **Control de cambios:** Esta versión conserva las decisiones válidas de la versión 1.0 e incorpora las decisiones aprobadas durante la revisión de compatibilidad e integración de los módulos. Las propuestas técnicas y entidades pendientes siguen sujetas a revisión y autorización.

---

## 1. Descripción general del sistema

R.I.C. es un sistema enfocado principalmente en el registro, administración y consulta de calificaciones escolares.

El sistema también contempla funciones complementarias necesarias para su funcionamiento, como:

- Administración de alumnos.
- Administración de profesores.
- Administración de grupos.
- Asignación de profesores y materias.
- Registro de asistencia.
- Configuración de criterios de evaluación.
- Registro y consulta de calificaciones.
- Solicitudes de corrección.
- Generación de reportes.

**Consideración importante:** El proyecto no pretende convertirse en un sistema administrativo escolar completo. Las funciones deben mantenerse dentro del alcance de las necesidades planteadas para R.I.C.

## 2. Roles del sistema

El sistema contempla dos roles:

### 2.1 Director

Puede:

- Administrar alumnos.
- Crear y administrar grupos.
- Registrar profesores.
- Crear credenciales iniciales para profesores.
- Asignar grupos a profesores.
- Consultar información académica.
- Configurar ciclos y periodos escolares.
- Autorizar o rechazar solicitudes de corrección.
- Consultar reportes.
- Administrar el estado de los profesores.

### 2.2 Profesor

Puede:

- Consultar sus grupos asignados.
- Consultar las materias que tiene asignadas.
- Crear materias en el catálogo compartido.
- Configurar criterios y ponderaciones.
- Registrar actividades.
- Capturar calificaciones.
- Registrar asistencias.
- Consultar información histórica de sus asignaciones.
- Solicitar autorización para corregir calificaciones.
- Exportar información a Excel.

### 2.3 Consideraciones generales

- Los alumnos no tendrán cuentas ni acceso al sistema.
- El rol `DIRECTOR` se almacena en la tabla `usuarios`; no se contempla una tabla independiente para directores.
- Las notificaciones serán internas, sin depender de servicios de correo externos.

## 3. Administración de alumnos

### 3.1 Registro y datos personales

El director será responsable de registrar alumnos.

Los datos contemplados son:

- Matrícula.
- Nombres.
- Apellidos.
- Fecha de nacimiento.

**Aclaración aprobada:** No se incorporará el campo `sexo` en la tabla `alumnos`, porque no se considera necesario para el objetivo principal de R.I.C.

La matrícula:

- Se captura manualmente.
- Debe ser única.
- Puede corregirse por el director.
- Los cambios deben conservar un historial con valor anterior, valor nuevo, motivo y responsable.

No se contempla almacenar CURP, domicilio, teléfonos ni información de tutores.

### 3.2 Importación de alumnos

Se permitirá:

- Registrar alumnos individualmente.
- Importar alumnos mediante una plantilla oficial de Excel.

La importación será parcial:

- Los registros correctos podrán guardarse.
- Los registros incorrectos quedarán identificados para su corrección.
- La importación no actualizará alumnos existentes.
- Las modificaciones de alumnos existentes se realizarán desde el formulario correspondiente.

### 3.3 Estados del alumno

Se contemplan los siguientes estados:

| Valor | Estado |
|---|---|
| 1 | ACTIVO |
| 2 | BAJA_TEMPORAL |
| 3 | BAJA_DEFINITIVA |

Los alumnos no se eliminarán físicamente de la base de datos.

**Baja temporal**

- Finaliza la inscripción vigente del alumno.
- Conserva sus calificaciones y asistencias.
- Permite una reincorporación posterior.
- La reincorporación genera una nueva inscripción.

**Baja definitiva**

- Finaliza la inscripción vigente.
- Conserva todo el historial académico.
- No permite una reincorporación ordinaria.
- El director puede revertirla mediante un procedimiento especial, registrando el motivo y conservando el historial de la baja original.

### 3.4 Inscripción en grupos

- Un alumno solo puede tener una inscripción activa en un grupo por ciclo escolar.
- Un cambio de grupo finaliza la inscripción anterior y genera una nueva.
- Las calificaciones y asistencias anteriores no se transfieren al nuevo grupo.
- Cada movimiento debe conservar fecha, responsable y motivo.

En la tabla `alumnos_grupos`:

| Valor | Estado |
|---|---|
| 1 | ACTIVA |
| 0 | FINALIZADA |

### 3.5 Cambios de grupo durante un periodo

Cuando un alumno cambie de grupo durante un periodo escolar:

1. Se finalizará su inscripción anterior.
2. Se creará una nueva inscripción en el grupo de destino.
3. Las calificaciones y asistencias anteriores permanecerán vinculadas a la inscripción original.
4. No se transferirán automáticamente calificaciones ni actividades al nuevo grupo.
5. El alumno utilizará la configuración de evaluación correspondiente al grupo de destino desde su incorporación.
6. La evaluación del nuevo grupo se calculará únicamente con las actividades correspondientes a la nueva inscripción.
7. No se combinarán los resultados de la inscripción anterior con los resultados de la nueva inscripción.
8. Los resultados anteriores permanecerán disponibles para consulta histórica.

Las actividades realizadas en el grupo de destino antes de la incorporación del alumno no se considerarán automáticamente en su evaluación.

### 3.6 Actividades de recuperación por incorporación o cambio de grupo

El profesor podrá asignar actividades de recuperación cuando un alumno se incorpore a un grupo después de que algunas actividades ya hayan sido realizadas.

Reglas acordadas:

- La recuperación sustituirá la evidencia de una actividad anterior que el alumno no tuvo oportunidad de realizar.
- La recuperación no se agregará como una actividad extra al promedio.
- La recuperación deberá corresponder al criterio de evaluación pertinente.
- La ponderación del criterio no cambiará por el hecho de realizar una recuperación.
- Se deberá conservar la relación histórica entre la actividad que se sustituye y la recuperación.

Los detalles técnicos para representar esta relación en la base de datos se definirán durante el diseño del módulo de Calificaciones. No se deben asumir campos o tablas adicionales antes de su aprobación.

### 3.7 Reincorporación después de una baja temporal

Cuando un alumno se reincorpore después de una baja temporal:

1. Se creará una nueva inscripción en `alumnos_grupos`.
2. La inscripción anterior permanecerá finalizada.
3. Las calificaciones y asistencias anteriores se conservarán y no se transferirán a la nueva inscripción.
4. El alumno continuará su evaluación desde la fecha de reincorporación.
5. Si se reincorpora al mismo grupo y al mismo periodo, podrá utilizar la configuración de evaluación vigente de ese grupo, siempre que siga vigente y no haya sido sustituida por una nueva versión.
6. Las actividades anteriores a la reincorporación no se asignarán automáticamente.
7. El profesor podrá asignar recuperaciones conforme a las reglas del apartado 3.6.
8. Se conservará el historial de ambas inscripciones.

La reincorporación no genera automáticamente una nueva versión de configuración de evaluación.

### 3.8 Promoción escolar

Al finalizar un ciclo escolar:

- El sistema podrá generar propuestas de promoción.
- El director decidirá individualmente el grado y grupo de cada alumno.
- Podrá promoverlo, mantenerlo en el mismo grado o cambiarlo de nivel.
- Los alumnos que terminen el último grado quedarán pendientes de decisión del director.
- El egreso será una acción administrativa explícita.

## 4. Administración de grupos

Cada grupo pertenece a un grado y a un ciclo escolar.

- Los grupos se crean para cada ciclo.
- Únicamente el director puede crear grupos.
- El director puede modificar su nombre y estado.
- Los grupos pueden desactivarse y reactivarse.
- La desactivación no elimina inscripciones ni registros históricos.

### 4.1 Capacidad del grupo

- Cada grupo debe tener una capacidad máxima obligatoria.
- La capacidad debe ser un número entero mayor que cero.
- No se permitirá superar la capacidad.
- No se permitirá reducirla por debajo de la cantidad de alumnos inscritos.
- El director podrá modificarla.
- Los cambios conservarán el valor anterior, valor nuevo, fecha, responsable y motivo.

El campo `capacidad_maxima` todavía no forma parte de la tabla `grupos` confirmada y requerirá revisión y aprobación técnica antes de modificar el esquema.

### 4.2 Cambios de grupo

Cuando un alumno cambie de grupo:

- Se finalizará su inscripción anterior.
- Se creará una nueva inscripción.
- Se registrará fecha, motivo y responsable.
- Se conservarán los registros académicos anteriores.
- Se aplicarán las reglas específicas del apartado 3.5 cuando el cambio ocurra durante un periodo escolar.

## 5. Profesores y asignaciones

### 5.1 Administración de profesores

- El director crea los perfiles docentes.
- El director proporciona las credenciales iniciales.
- El profesor puede cambiar su contraseña.
- Si un profesor deja la institución, el director desactiva su usuario.
- No se eliminan físicamente los profesores ni sus registros.
- No se permitirá desactivar un profesor que todavía tenga asignaciones activas o programadas sin resolver.

### 5.2 Asignaciones docentes

- Un profesor puede tener varios grupos.
- Un grupo puede tener varios profesores.
- No se permitirá más de una asignación activa para la misma combinación profesor-grupo.
- Las asignaciones conservarán su historial.
- Los cambios de profesor no eliminarán los registros anteriores.

Se contemplan:

- Asignaciones activas.
- Asignaciones programadas.
- Asignaciones finalizadas.
- Asignaciones canceladas.

Los cambios programados podrán cancelarse antes de comenzar, conservando el registro de la cancelación.

### 5.3 Materias

- Existirá un catálogo compartido de materias.
- Los profesores podrán crear materias.
- Se evitarán materias duplicadas, incluso cuando cambien mayúsculas o minúsculas.
- Se identificará al usuario que registró cada materia.
- Solo el profesor creador podrá desactivar una materia, siempre que no esté siendo utilizada en una asignación activa.
- Las materias no se eliminarán físicamente.

### 5.4 Materias asignadas

- Cada materia dentro de un grupo tendrá un profesor responsable en un intervalo determinado.
- No se permitirá que dos profesores tengan simultáneamente la misma materia asignada al mismo grupo.
- Cuando un profesor termine una materia, finalizará su asignación, pero la materia continuará disponible en el catálogo.
- Los registros históricos permanecerán relacionados con la asignación original.
- El profesor conservará acceso de consulta a sus registros históricos, aunque su asignación haya terminado.
- No podrá realizar nuevas capturas en una asignación finalizada, salvo correcciones específicas autorizadas.

### 5.5 Sustitución de profesor durante un periodo

Cuando un profesor deje de impartir una materia a un grupo y otro profesor lo sustituya:

1. La asignación anterior se finalizará.
2. El profesor sustituto tendrá una nueva asignación de materia.
3. Las actividades y calificaciones anteriores permanecerán relacionadas con la asignación original y conservarán su autoría e historial.
4. El nuevo profesor podrá consultar la información académica anterior necesaria para continuar el trabajo.
5. El nuevo profesor podrá crear nuevas actividades y capturar nuevas calificaciones conforme a las reglas del sistema.
6. Las nuevas actividades y capturas deberán identificar al profesor responsable y su nueva asignación docente.
7. No se modificarán ni transferirán las calificaciones anteriores.
8. El profesor anterior conservará acceso de consulta a sus registros históricos.

### 5.6 Continuidad de la configuración cuando cambia el profesor

El cambio de profesor, por sí solo, **no genera una nueva versión de la configuración de evaluación**.

Reglas:

- La configuración de evaluación pertenece a la combinación de materia, grupo y periodo, no exclusivamente a la asignación de un profesor.
- El profesor sustituto continuará utilizando la configuración vigente que ya tenía la materia en ese grupo y periodo.
- Las actividades anteriores conservarán su relación histórica con el profesor y la asignación docente que las originó.
- El profesor sustituto podrá crear nuevas actividades utilizando la misma configuración vigente.
- Las nuevas actividades deberán conservar la identificación del nuevo profesor y su asignación.
- Si el profesor sustituto modifica criterios o ponderaciones, se creará una nueva versión de configuración conforme al apartado 7.
- La sustitución docente no modifica retroactivamente las actividades, calificaciones ni resultados anteriores.

## 6. Ciclos y periodos escolares

Los ciclos escolares y los periodos serán configurables.

El director podrá establecer:

- Nombre del ciclo.
- Fecha de inicio.
- Fecha de finalización.
- Cantidad de periodos.
- Nombre de cada periodo.
- Fecha de inicio y finalización de cada periodo.
- Fecha límite de captura.

El director podrá cerrar manualmente un periodo.

La fecha límite de captura bloqueará las modificaciones ordinarias, incluso si el periodo todavía no se ha cerrado formalmente.

Después del cierre, las correcciones se realizarán mediante solicitudes autorizadas, sin reabrir todo el periodo.

La entidad `periodos` no forma parte de las once tablas físicas confirmadas actualmente. Su estructura deberá aprobarse antes de implementarse.

## 7. Evaluación y calificaciones

### 7.1 Configuración de evaluación

Cada combinación de materia, grupo y periodo tendrá su propia configuración de evaluación.

La configuración no pertenecerá exclusivamente a un profesor ni a una asignación docente individual. Esto permite que continúe vigente cuando un profesor sea sustituido.

El profesor podrá:

- Crear criterios de evaluación.
- Asignar ponderaciones.
- Registrar actividades dentro de los criterios.

Reglas:

- Las ponderaciones de los criterios deberán sumar el 100%.
- Las actividades pertenecientes a un mismo criterio tendrán el mismo peso y sus calificaciones se promediarán.
- Las actividades y calificaciones deberán conservar la identificación del profesor responsable y de la asignación docente que las originó.

### 7.2 Calificaciones pendientes

Una calificación pendiente se almacenará como `NULL`, no como cero.

Esto permitirá distinguir entre:

- Un alumno que obtuvo cero.
- Un alumno que todavía no tiene calificación registrada.

### 7.3 Historial de configuraciones

Se acordó permitir modificaciones en las ponderaciones conservando versiones anteriores.

Cada versión deberá conservar:

- Criterios.
- Ponderaciones.
- Fecha de modificación.
- Profesor responsable de la modificación.
- Periodo de vigencia.

Cuando el profesor cambie la configuración:

- La configuración anterior conservará sus actividades y resultados.
- Las actividades anteriores no se modificarán ni recalcularán.
- Las nuevas actividades utilizarán la nueva configuración.
- Los resultados de cada versión se calcularán por separado.
- Los resultados de las distintas versiones se combinarán para obtener la calificación del periodo.

Un cambio de profesor no genera automáticamente una versión nueva. Una modificación real de criterios o ponderaciones sí genera una nueva versión.

### 7.4 Combinación de configuraciones

Se eligió como criterio de diseño el peso proporcional al tiempo de vigencia de cada configuración.

Ejemplo ilustrativo:

Un periodo dura 90 días:

- Primera configuración: vigente durante 80 días.
- Segunda configuración: vigente durante 10 días.

La distribución proporcional sería:

| Configuración | Días de vigencia | Peso |
|---|---:|---:|
| Versión 1 | 80 | 88.89 % |
| Versión 2 | 10 | 11.11 % |
| Total | 90 | 100 % |

Se recomienda permitir cambios incluso cerca del final del periodo, siempre que se conserve el historial y se aplique la ponderación proporcional.

Pendiente de aprobación definitiva: establecer si el cálculo utilizará días naturales o días lectivos, así como las reglas exactas para determinar la vigencia de cada versión.

### 7.5 Configuraciones sin calificaciones

Cuando un profesor modifique la configuración de evaluación y la versión anterior todavía no tenga calificaciones:

- Se permitirá crear la nueva versión.
- La versión anterior se conservará en el historial.
- Se registrará su tiempo de vigencia y su peso proporcional.
- Si no tiene resultados registrados, no participará en el cálculo de la calificación final.
- Los pesos de las versiones que sí tengan resultados se normalizarán proporcionalmente para calcular la calificación final.
- La nueva versión se aplicará únicamente a las actividades creadas a partir de su entrada en vigor.

Ejemplo:

| Configuración | Vigencia | Peso original | Peso efectivo |
|---|---:|---:|---:|
| Versión 1 (sin resultados) | 20 días | 22.22 % | 0 % |
| Versión 2 (con resultados) | 70 días | 77.78 % | 100 % |

La primera versión permanece en el historial, pero no perjudica al alumno.

### 7.6 Relación de calificaciones con alumnos, grupos y materias

Todos los alumnos inscritos en un grupo cursarán las materias que estén asignadas a ese grupo.

Por lo tanto:

- No se administrarán inscripciones individuales por materia.
- La relación del alumno con el grupo se obtendrá mediante `alumnos_grupos`.
- La relación de la materia con el grupo se obtendrá mediante `materias_asignadas` y su asignación docente.
- Las futuras calificaciones deberán identificar la inscripción del alumno y la actividad evaluada.
- Mediante la actividad y sus relaciones se deberá poder identificar la configuración, materia, grupo, periodo y contexto docente correspondientes.

La alternativa de aprovechar las relaciones existentes es el criterio de diseño aprobado para continuar el análisis. La estructura física definitiva de las tablas de evaluación y las restricciones para validar que el alumno y la materia correspondan al mismo grupo siguen pendientes de diseño y aprobación.

No se contempla crear una entidad de inscripción individual por materia bajo la regla actual de que todos los alumnos del grupo cursan todas las materias asignadas a ese grupo.

### 7.7 Cambios de grupo y evaluación

Cuando un alumno cambie de grupo durante un periodo:

- Las calificaciones anteriores permanecerán asociadas a su inscripción original.
- La nueva inscripción utilizará la configuración de evaluación del grupo de destino.
- La evaluación de la nueva inscripción se calculará únicamente con las actividades correspondientes a esa inscripción.
- No se combinarán los resultados del grupo anterior con los del nuevo grupo.
- Las actividades realizadas antes de la incorporación no se asignarán automáticamente.
- El profesor podrá asignar recuperaciones conforme al apartado 3.6.

### 7.8 Reincorporaciones y evaluación

Cuando un alumno se reincorpore al mismo grupo y periodo después de una baja temporal:

- Se creará una nueva inscripción.
- Las calificaciones anteriores permanecerán asociadas a la inscripción finalizada.
- El alumno continuará su evaluación desde la fecha de reincorporación.
- Podrá utilizarse la configuración vigente del grupo si no ha sido sustituida por una nueva versión.
- Las actividades anteriores a la reincorporación no se asignarán automáticamente.
- El profesor podrá asignar recuperaciones conforme al apartado 3.6.

### 7.9 Actividades de recuperación

Las actividades de recuperación destinadas a alumnos que se incorporan o reincorporan después de que se hayan realizado actividades deberán:

- Identificar la actividad cuya evidencia sustituyen.
- Pertenecer al criterio de evaluación correspondiente.
- No contarse como una actividad adicional al promedio.
- Conservar la identificación del profesor responsable y el contexto de inscripción del alumno.

La representación técnica de la sustitución, las validaciones para evitar duplicidades y el tratamiento de casos en los que no exista una actividad equivalente deberán definirse antes de implementar el esquema y el cálculo.

## 8. Asistencia

El profesor registrará asistencia por materia asignada, grupo y fecha.

Se contemplan los siguientes estados:

- PRESENTE.
- AUSENTE.
- RETARDO.
- JUSTIFICADO.

El profesor podrá marcar directamente una asistencia como justificada.

También se permitirá:

- Registrar asistencia retroactiva dentro del periodo permitido.
- Modificar registros.
- Conservar un historial de modificaciones.
- Mantener los registros de alumnos que posteriormente causen baja.

El registro deberá distinguir la fecha de la sesión de la fecha y hora en que realmente se capturó.

La asistencia deberá poder asociarse con la inscripción del alumno correspondiente a la fecha de la sesión, para conservar el historial ante cambios de grupo o reincorporaciones.

Las tablas de asistencia siguen pendientes de aprobación e implementación.

## 9. Solicitudes de corrección de calificaciones

Cuando termine el plazo ordinario de captura, el profesor necesitará autorización del director para corregir calificaciones.

### 9.1 Responsabilidad del módulo

El módulo de Solicitudes y Reportes administrará el flujo de solicitudes, autorizaciones, extensiones, vencimientos e historial.

El módulo Director proporcionará las interfaces y acciones para que el Director revise y tome las decisiones de aprobación o rechazo.

El módulo de Calificaciones será responsable de ejecutar la modificación autorizada de la calificación y conservar su historial.

El módulo Profesor permitirá crear solicitudes, consultar sus estados y capturar las correcciones autorizadas.

Esta distribución evita duplicar la lógica de solicitudes y evita que dos módulos modifiquen independientemente el mismo registro de calificación.

### 9.2 Creación de solicitudes

Una solicitud podrá incluir varias calificaciones.

Cada calificación se revisará individualmente.

El profesor:

- Seleccionará la calificación que necesita corregir.
- Explicará el error.
- No propondrá directamente el nuevo valor.

### 9.3 Autorización

El director podrá:

- Aprobar una corrección.
- Rechazar una corrección.
- Establecer un límite de tiempo para realizarla.

Si se autoriza, el profesor podrá capturar el nuevo valor dentro del plazo establecido.

La autorización se limita a la calificación indicada y no reabre el periodo completo.

### 9.4 Estados de los detalles de solicitud

Se contemplan:

- PENDIENTE.
- APROBADA.
- RECHAZADA.
- COMPLETADA.
- VENCIDA.

Cada detalle se resolverá individualmente, aunque forme parte de una solicitud con varias calificaciones.

### 9.5 Extensiones

- El profesor podrá solicitar una extensión antes de que venza la autorización.
- El director podrá aprobarla o rechazarla.
- No se permitirán extensiones después del vencimiento.
- Si vence, será necesario generar una nueva solicitud.
- Las solicitudes pendientes se conservarán aunque el profesor termine su asignación.

### 9.6 Correcciones relacionadas con asignaciones terminadas

Las solicitudes y autorizaciones se conservarán aunque la asignación docente haya terminado.

El Director podrá resolver solicitudes pendientes relacionadas con asignaciones anteriores. Una autorización específica podrá permitir la corrección de la calificación indicada, sin reactivar la asignación ni habilitar nuevas capturas ordinarias.

## 10. Notificaciones internas

Las notificaciones serán administradas dentro del sistema.

No se utilizarán correos externos.

Se contemplan notificaciones para:

**Profesor:**
- Solicitud aprobada o rechazada.
- Límite temporal de una autorización.
- Extensión aprobada o rechazada.
- Autorización vencida.

**Director:**
- Nueva solicitud de corrección.
- Nueva solicitud de extensión.

Las notificaciones podrán agruparse por solicitud.

Cuando una notificación reciba nueva información, deberá volver a marcarse como no leída.

La estructura física de notificaciones sigue pendiente de diseño y aprobación.

## 11. Seguridad y cuentas

Se contemplan las siguientes reglas:

- El director podrá restablecer contraseñas de profesores.
- Las contraseñas temporales tendrán una duración de 24 horas.
- Serán de un solo uso.
- Se almacenarán mediante hash.
- El profesor deberá cambiar la contraseña temporal al iniciar sesión.
- Cinco intentos fallidos bloquearán la cuenta durante 15 minutos.
- Se conservará un historial de accesos exitosos, fallidos, bloqueos y desbloqueos.
- El historial de accesos se conservará durante un año.
- Solo el director podrá consultarlo.

El cierre automático de sesión podrá configurarse individualmente:

- 15 minutos.
- 30 minutos.
- 60 minutos.
- 120 minutos.
- Deshabilitado.

El valor predeterminado será 30 minutos.

## 12. Estructura actual de la base de datos

De acuerdo con el respaldo actualizado de MySQL compartido el 23 de noviembre de 2026, se identificaron once tablas físicas:

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

Estas once tablas constituyen la referencia física actual del diseño.

**Importante:** Las siguientes entidades se han planteado durante el diseño, pero no deben considerarse existentes físicamente hasta que se confirme su creación en MySQL:

- `periodos`
- `configuraciones_evaluacion`
- `criterios_evaluacion`
- `actividades`
- `calificaciones`
- `historial_calificaciones`
- `asistencias`
- `detalle_asistencia`
- `historial_asistencias`
- `solicitudes_correccion`
- `detalles_solicitud_correccion`
- `extensiones_autorizacion`

La lista es una recopilación de entidades propuestas, no una instrucción para crearlas todas automáticamente.

También requieren diseño y aprobación los mecanismos de notificaciones, historial de movimientos de alumnos, historial de cambios de datos personales y cualquier otra estructura adicional que resulte necesaria.

## 13. Reglas de trabajo para el equipo de desarrollo

Para mantener la integración del proyecto:

- Cada integrante deberá trabajar en su módulo y rama correspondiente.
- No se crearán tablas nuevas por cuenta propia.
- No se modificarán tablas existentes sin autorización del responsable de arquitectura y base de datos.
- Si un módulo necesita un campo, relación o entidad adicional, deberá solicitarse primero.
- No se asumirá que una tabla propuesta ya existe físicamente.
- Los módulos deberán utilizar la misma base de datos.
- Se respetará la arquitectura MVC + DAO + Service.
- La conexión JDBC y la configuración general del proyecto serán centralizadas.
- Las interfaces comunes deberán mantener una estructura consistente.
- Los cambios deberán integrarse mediante Git y revisarse antes de incorporarse a la rama principal.

## 14. Consideración final

Este documento funciona como referencia compartida para el desarrollo de R.I.C.

Las decisiones marcadas como pendientes o propuestas no deberán implementarse como reglas definitivas hasta que sean aprobadas.

Cualquier necesidad nueva deberá revisarse para comprobar que corresponde al alcance del proyecto y que no contradice decisiones anteriores.

---

## 15. Registro de cambios de la versión 1.1

La versión 1.1 incorpora y armoniza las siguientes decisiones aprobadas durante la revisión de compatibilidad e integración:

1. Se elimina `sexo` de los datos contemplados para la tabla `alumnos`.
2. Se aclara que las once tablas enumeradas en el apartado 12 son las tablas físicas confirmadas.
3. Se establece que todos los alumnos inscritos en un grupo cursan las materias asignadas a ese grupo; no se administrarán inscripciones individuales por materia.
4. Se establece que la relación propuesta para calificaciones aprovechará `alumnos_grupos` y las actividades de evaluación, sujeto al diseño físico y sus validaciones.
5. Se establece que una sustitución docente genera una nueva asignación, conserva las actividades y calificaciones anteriores y no transfiere su autoría.
6. Se establece que el cambio de profesor no genera automáticamente una nueva versión de configuración.
7. Se establece que la configuración de evaluación pertenece a materia, grupo y periodo, no exclusivamente al profesor o a su asignación docente.
8. Se establece que el profesor sustituto puede continuar utilizando la configuración vigente y crear nuevas actividades bajo su nueva asignación.
9. Se establece que un cambio real de criterios o ponderaciones genera una nueva versión.
10. Se detallan las reglas de evaluación para alumnos que cambian de grupo durante un periodo.
11. Se establece que los resultados de inscripciones de grupos distintos no se combinan.
12. Se incorpora la regla de actividades de recuperación: sustituyen la evidencia de una actividad no realizada y no se agregan como actividades adicionales al promedio.
13. Se detallan las reglas de reincorporación después de una baja temporal, incluyendo la creación de una nueva inscripción y la continuidad de la configuración vigente cuando corresponda.
14. Se aclara la distribución de responsabilidades entre Solicitudes y Reportes, Director, Profesor y Calificaciones.

**Nota:** Esta versión actualiza las reglas funcionales y la documentación. No autoriza cambios automáticos en la estructura física de MySQL. Las tablas, campos, relaciones, restricciones e índices pendientes deberán revisarse y aprobarse por el responsable de arquitectura y base de datos antes de su implementación.
