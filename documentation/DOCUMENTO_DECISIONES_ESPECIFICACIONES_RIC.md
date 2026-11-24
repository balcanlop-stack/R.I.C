R.I.C. — Registro Integral de Calificaciones

Documento de decisiones y especificaciones funcionales

Versión: 1.0 — Borrador de trabajo
Objetivo: Compartir con los integrantes del equipo las decisiones funcionales, reglas de negocio y consideraciones técnicas acordadas para desarrollar los módulos del sistema R.I.C.

## 1. Descripción general del sistema

R.I.C. es un sistema enfocado principalmente en el registro, administración y consulta de calificaciones escolares.

El sistema también contempla funciones complementarias necesarias para su funcionamiento, como:

Administración de alumnos.

Administración de profesores.

Administración de grupos.

Asignación de profesores y materias.

Registro de asistencia.

Configuración de criterios de evaluación.

Registro y consulta de calificaciones.

Solicitudes de corrección.

Generación de reportes.

Consideración importante: El proyecto no pretende convertirse en un sistema administrativo escolar completo. Las funciones deben mantenerse dentro del alcance de las necesidades planteadas para R.I.C.

## 2. Roles del sistema

El sistema contempla dos roles:

### Director

Puede:

Administrar alumnos.

Crear y administrar grupos.

Registrar profesores.

Crear credenciales iniciales para profesores.

Asignar grupos a profesores.

Consultar información académica.

Configurar ciclos y periodos escolares.

Autorizar o rechazar solicitudes de corrección.

Consultar reportes.

Administrar el estado de los profesores.

### Profesor

Puede:

Consultar sus grupos asignados.

Consultar las materias que tiene asignadas.

Crear materias en el catálogo compartido.

Configurar criterios y ponderaciones.

Registrar actividades.

Capturar calificaciones.

Registrar asistencias.

Consultar información histórica de sus asignaciones.

Solicitar autorización para corregir calificaciones.

Exportar información a Excel.

Consideraciones

Los alumnos no tendrán cuentas ni acceso al sistema.

El rol DIRECTOR se almacena en la tabla usuarios; no se contempla una tabla independiente para directores.

Las notificaciones serán internas, sin depender de servicios de correo externos.

## 3. Administración de alumnos

### 3.1 Registro y datos personales

El director será responsable de registrar alumnos.

Los datos contemplados son:

Matrícula.

Nombres.

Apellidos.

Fecha de nacimiento.

Sexo.

La matrícula:

Se captura manualmente.

Debe ser única.

Puede corregirse por el director.

Los cambios deben conservar un historial con valor anterior, valor nuevo, motivo y responsable.

No se contempla almacenar CURP, domicilio, teléfonos ni información de tutores.

### 3.2 Importación de alumnos

Se permitirá:

Registrar alumnos individualmente.

Importar alumnos mediante una plantilla oficial de Excel.

La importación será parcial:

Los registros correctos podrán guardarse.

Los registros incorrectos quedarán identificados para su corrección.

La importación no actualizará alumnos existentes.

Las modificaciones de alumnos existentes se realizarán desde el formulario correspondiente.

### 3.3 Estados del alumno

Se contemplan los siguientes estados:


| Valor | Estado |
| --- | --- |
| 1 | ACTIVO |
| 2 | BAJA_TEMPORAL |
| 3 | BAJA_DEFINITIVA |


Los alumnos no se eliminarán físicamente de la base de datos.

Baja temporal

Finaliza la inscripción vigente del alumno.

Conserva sus calificaciones y asistencias.

Permite una reincorporación posterior.

La reincorporación genera una nueva inscripción.

Baja definitiva

Finaliza la inscripción vigente.

Conserva todo el historial académico.

No permite una reincorporación ordinaria.

El director puede revertirla mediante un procedimiento especial, registrando el motivo y conservando el historial de la baja original.

### 3.4 Inscripción en grupos

Un alumno solo puede tener una inscripción activa en un grupo por ciclo escolar.

Un cambio de grupo finaliza la inscripción anterior y genera una nueva.

Las calificaciones y asistencias anteriores no se transfieren al nuevo grupo.

Cada movimiento debe conservar fecha, responsable y motivo.

### 3.5 Promoción escolar

Al finalizar un ciclo escolar:

El sistema podrá generar propuestas de promoción.

El director decidirá individualmente el grado y grupo de cada alumno.

Podrá promoverlo, mantenerlo en el mismo grado o cambiarlo de nivel.

Los alumnos que terminen el último grado quedarán pendientes de decisión del director.

El egreso será una acción administrativa explícita.

## 4. Administración de grupos

Cada grupo pertenece a un grado y a un ciclo escolar.

Los grupos se crean para cada ciclo.

Únicamente el director puede crear grupos.

El director puede modificar su nombre y estado.

Los grupos pueden desactivarse y reactivarse.

La desactivación no elimina inscripciones ni registros históricos.

### 4.1 Capacidad del grupo

Cada grupo debe tener una capacidad máxima obligatoria.

La capacidad debe ser un número entero mayor que cero.

No se permitirá superar la capacidad.

No se permitirá reducirla por debajo de la cantidad de alumnos inscritos.

El director podrá modificarla.

Los cambios conservarán el valor anterior, valor nuevo, fecha, responsable y motivo.

### 4.2 Cambios de grupo

Cuando un alumno cambie de grupo:

Se finalizará su inscripción anterior.

Se creará una nueva inscripción.

Se registrará fecha, motivo y responsable.

Se conservarán los registros académicos anteriores.

## 5. Profesores y asignaciones

### 5.1 Administración de profesores

El director crea los perfiles docentes.

El director proporciona las credenciales iniciales.

El profesor puede cambiar su contraseña.

Si un profesor deja la institución, el director desactiva su usuario.

No se eliminan físicamente los profesores ni sus registros.

No se permitirá desactivar un profesor que todavía tenga asignaciones activas o programadas sin resolver.

### 5.2 Asignaciones docentes

Un profesor puede tener varios grupos.

Un grupo puede tener varios profesores.

No se permitirá más de una asignación activa para la misma combinación profesor-grupo.

Las asignaciones conservarán su historial.

Los cambios de profesor no eliminarán los registros anteriores.

Se contempla:

Asignaciones activas.

Asignaciones programadas.

Asignaciones finalizadas.

Asignaciones canceladas.

Los cambios programados podrán cancelarse antes de comenzar, conservando el registro de la cancelación.

### 5.3 Materias

Existirá un catálogo compartido de materias.

Los profesores podrán crear materias.

Se evitarán materias duplicadas, incluso cuando cambien mayúsculas o minúsculas.

Se identificará al usuario que registró cada materia.

Solo el profesor creador podrá desactivar una materia, siempre que no esté siendo utilizada en una asignación activa.

Las materias no se eliminarán físicamente.

### 5.4 Materias asignadas

Cada materia dentro de un grupo tendrá un profesor responsable en un intervalo determinado.

No se permitirá que dos profesores tengan simultáneamente la misma materia asignada al mismo grupo.

Cuando un profesor termine una materia, finalizará su asignación, pero la materia continuará disponible en el catálogo.

Los registros históricos permanecerán relacionados con la asignación original.

El profesor conservará acceso de consulta a sus registros históricos, aunque su asignación haya terminado.

No podrá realizar nuevas capturas en una asignación finalizada, salvo correcciones específicas autorizadas.

## 6. Ciclos y periodos escolares

Los ciclos escolares y los periodos serán configurables.

El director podrá establecer:

Nombre del ciclo.

Fecha de inicio.

Fecha de finalización.

Cantidad de periodos.

Nombre de cada periodo.

Fecha de inicio y finalización de cada periodo.

Fecha límite de captura.

El director podrá cerrar manualmente un periodo.

La fecha límite de captura bloqueará las modificaciones ordinarias, incluso si el periodo todavía no se ha cerrado formalmente.

Después del cierre, las correcciones se realizarán mediante solicitudes autorizadas, sin reabrir todo el periodo.

## 7. Evaluación y calificaciones

### 7.1 Configuración de evaluación

Cada combinación de materia, grupo y periodo tendrá su propia configuración de evaluación.

El profesor podrá:

Crear criterios de evaluación.

Asignar ponderaciones.

Registrar actividades dentro de los criterios.

Las ponderaciones de los criterios deberán sumar el 100%.

Las actividades pertenecientes a un mismo criterio tendrán el mismo peso y sus calificaciones se promediarán.

### 7.2 Calificaciones pendientes

Una calificación pendiente se almacenará como NULL, no como cero.

Esto permitirá distinguir entre:

Un alumno que obtuvo cero.

Un alumno que todavía no tiene calificación registrada.

### 7.3 Historial de configuraciones

Se acordó permitir modificaciones en las ponderaciones conservando versiones anteriores.

Cada versión deberá conservar:

Criterios.

Ponderaciones.

Fecha de modificación.

Profesor responsable.

Periodo de vigencia.

Cuando el profesor cambie la configuración:

La configuración anterior conservará sus actividades y resultados.

Las actividades anteriores no se modificarán ni recalcularán.

Las nuevas actividades utilizarán la nueva configuración.

Los resultados de cada versión se calcularán por separado.

Los resultados de las distintas versiones se combinarán para obtener la calificación del periodo.

### 7.4 Combinación de configuraciones

Se eligió como criterio de diseño el peso proporcional al tiempo de vigencia de cada configuración.

Ejemplo ilustrativo:

Un periodo dura 90 días:

Primera configuración: vigente durante 80 días.

Segunda configuración: vigente durante 10 días.

La distribución proporcional sería:


| Configuración | Días de vigencia | Peso |
| --- | --- | --- |
| Versión 1 | 80 | 88.89 % |
| Versión 2 | 10 | 11.11 % |
| Total | 90 | 100 % |


Se recomienda permitir cambios incluso cerca del final del periodo, siempre que se conserve el historial y se aplique la ponderación proporcional.

Pendiente de aprobación definitiva: establecer si el cálculo utilizará días naturales o días lectivos, así como las reglas exactas para determinar la vigencia de cada versión.

7.5 configuraciones sin calificaciones

Cuando un profesor modifique la configuración de evaluación y la versión anterior todavía no tenga calificaciones:

Se permitirá crear la nueva versión.

La versión anterior se conservará en el historial.

Se registrará su tiempo de vigencia y su peso proporcional.

Si no tiene resultados registrados, no participará en el cálculo de la calificación final.

Los pesos de las versiones que sí tengan resultados se normalizarán proporcionalmente para calcular la calificación final.

La nueva versión se aplicará únicamente a las actividades creadas a partir de su entrada en vigor.

Ejemplo:


| Configuración | Vigencia | Peso original | Peso efectivo |
| --- | --- | --- | --- |
| Versión 1 (sin resultados) | 20 días | 22.22 % | 0 % |
| Versión 2 (con resultados) | 70 días | 77.78 % | 100 % |


La primera versión permanece en el historial, pero no perjudica al alumno.

## 8. Asistencia

El profesor registrará asistencia por materia asignada, grupo y fecha.

Se contemplan los siguientes estados:

PRESENTE.

AUSENTE.

RETARDO.

JUSTIFICADO.

El profesor podrá marcar directamente una asistencia como justificada.

También se permitirá:

Registrar asistencia retroactiva dentro del periodo permitido.

Modificar registros.

Conservar un historial de modificaciones.

Mantener los registros de alumnos que posteriormente causen baja.

El registro deberá distinguir la fecha de la sesión de la fecha y hora en que realmente se capturó.

## 9. Solicitudes de corrección de calificaciones

Cuando termine el plazo ordinario de captura, el profesor necesitará autorización del director para corregir calificaciones.

### 9.1 Creación de solicitudes

Una solicitud podrá incluir varias calificaciones.

Cada calificación se revisará individualmente.

El profesor seleccionará la calificación que necesita corregir.

Deberá explicar el error.

No propondrá directamente el nuevo valor.

### 9.2 Autorización

El director podrá:

Aprobar una corrección.

Rechazar una corrección.

Establecer un límite de tiempo para realizarla.

Si se autoriza, el profesor podrá capturar el nuevo valor dentro del plazo establecido.

### 9.3 Estados de las solicitudes

Se contemplan:

PENDIENTE.

APROBADA.

RECHAZADA.

COMPLETADA.

VENCIDA.

### 9.4 Extensiones

El profesor podrá solicitar una extensión antes de que venza la autorización.

El director podrá aprobarla o rechazarla.

No se permitirán extensiones después del vencimiento.

Si vence, será necesario generar una nueva solicitud.

Las solicitudes pendientes se conservarán aunque el profesor termine su asignación.

## 10. Notificaciones internas

Las notificaciones serán administradas dentro del sistema.

No se utilizarán correos externos.

Se contemplan notificaciones para:

Profesor:

Solicitud aprobada o rechazada.

Autorización próxima a vencer.

Extensión aprobada o rechazada.

Autorización vencida.

Director:

Nueva solicitud de corrección.

Nueva solicitud de extensión.

Las notificaciones podrán agruparse por solicitud.

Cuando una notificación reciba nueva información, deberá volver a marcarse como no leída.

## 11. Seguridad y cuentas

Se contemplan las siguientes reglas:

El director podrá restablecer contraseñas de profesores.

Las contraseñas temporales tendrán una duración de 24 horas.

Serán de un solo uso.

Se almacenarán mediante hash.

El profesor deberá cambiar la contraseña temporal al iniciar sesión.

Cinco intentos fallidos bloquearán la cuenta durante 15 minutos.

Se conservará un historial de accesos exitosos, fallidos, bloqueos y desbloqueos.

El historial de accesos se conservará durante un año.

Solo el director podrá consultarlo.

El cierre automático de sesión podrá configurarse individualmente:

15 minutos.

30 minutos.

60 minutos.

120 minutos.

Deshabilitado.

El valor predeterminado será 30 minutos.

## 12. Estructura actual de la base de datos

De acuerdo con el respaldo actualizado de MySQL compartido el 23 de noviembre de 2026, se identificaron once tablas físicas:

usuarios

profesores

niveles_educativos

ciclos_escolares

grados

grupos

alumnos

alumnos_grupos

Las once tablas físicas confirmadas son: `usuarios`, `profesores`, `niveles_educativos`, `ciclos_escolares`, `grados`, `grupos`, `alumnos`, `alumnos_grupos`, `asignaciones_docentes`, `materias` y `materias_asignadas`.

Estas tablas constituyen la referencia física actual del diseño.

Importante: Las siguientes entidades se han planteado durante el diseño, pero no deben considerarse existentes físicamente hasta que se confirme su creación:

asignaciones_docentes

materias

materias_asignadas

periodos

configuraciones_evaluacion

criterios_evaluacion

actividades

calificaciones

historial_calificaciones

asistencias

detalle_asistencia

historial_asistencias

solicitudes_correccion

detalles_solicitud_correccion

extensiones_autorizacion

La lista es una recopilación de entidades propuestas, no una instrucción para crearlas todas automáticamente.

## 13. Reglas de trabajo para el equipo de desarrollo

Para mantener la integración del proyecto:

Cada integrante deberá trabajar en su módulo y rama correspondiente.

No se crearán tablas nuevas por cuenta propia.

No se modificarán tablas existentes sin autorización del responsable de arquitectura y base de datos.

Si un módulo necesita un campo, relación o entidad adicional, deberá solicitarse primero.

No se asumirá que una tabla propuesta ya existe físicamente.

Los módulos deberán utilizar la misma base de datos.

Se respetará la arquitectura MVC + DAO + Service.

La conexión JDBC y la configuración general del proyecto serán centralizadas.

Las interfaces comunes deberán mantener una estructura consistente.

Los cambios deberán integrarse mediante Git y revisarse antes de incorporarse a la rama principal.

## 14. Consideración final

Este documento funciona como referencia compartida para el desarrollo de R.I.C.

Las decisiones marcadas como pendientes o propuestas no deberán implementarse como reglas definitivas hasta que sean aprobadas.

Cualquier necesidad nueva deberá revisarse para comprobar que corresponde al alcance del proyecto y que no contradice decisiones anteriores.


## Actualizaciones aprobadas después de la versión Word 1.0

Las siguientes decisiones se confirmaron durante la revisión del diccionario de datos y complementan o sustituyen el borrador original:

### Administración de alumnos
- No se incorporará el campo `sexo` en `alumnos`; se considera innecesario para el objetivo principal de R.I.C.
- En `alumnos_grupos.estado`: `1 = ACTIVA` y `0 = FINALIZADA`.
- Los cambios de grupo finalizan la inscripción anterior y crean una nueva, conservando la inscripción histórica.
- Se mantiene el historial de movimientos: alta, cambio de grupo, promoción, baja temporal, reincorporación, baja definitiva y reversión.

### Estructura escolar
- El director crea y administra los niveles educativos; puede desactivarlos sin eliminar sus grados.
- Solo puede existir un ciclo escolar activo a la vez.
- El director administra los grados; no se elimina un grado que tenga grupos relacionados.
- Cada grupo tendrá una capacidad máxima obligatoria. El campo `capacidad_maxima` aún no existe en la tabla `grupos` y requerirá revisión y aprobación técnica antes de modificar el esquema.

### Asignaciones docentes y materias
- El director no crea materias directamente en el catálogo; los profesores pueden crearlas.
- El profesor selecciona las materias que impartirá dentro de sus grupos asignados.
- Las asignaciones programadas se activarán automáticamente al llegar su fecha de inicio.
- Al finalizar una asignación, el profesor conserva acceso de consulta a sus registros históricos, pero no realiza nuevas capturas ordinarias.
- Una misma materia no puede estar asignada más de una vez dentro del mismo grupo mientras exista una asignación vigente, aunque se trate de profesores diferentes.
- Cuando la asignación anterior de esa materia haya finalizado, otro profesor podrá impartirla posteriormente en el mismo grupo.
- La misma materia sí puede impartirse en distintos grupos.

### Estado de la base de datos
- El respaldo actualizado contiene once tablas físicas, incluidas `asignaciones_docentes`, `materias` y `materias_asignadas`.
- No se deben considerar físicamente existentes las demás entidades propuestas hasta que se confirme su creación en MySQL.
