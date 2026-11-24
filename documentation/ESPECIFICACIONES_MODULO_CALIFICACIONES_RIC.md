# R.I.C. — Especificaciones del módulo de Calificaciones

**Versión:** 1.0  
**Estado:** Borrador para revisión  
**Proyecto:** Registro Integral de Calificaciones (R.I.C.)

---

## 1. Propósito del módulo

El módulo de Calificaciones permitirá al profesor configurar y administrar la evaluación de sus materias y grupos, registrar calificaciones de actividades y consultar los resultados de los alumnos durante el periodo escolar.

El módulo deberá conservar el historial de las configuraciones y de las calificaciones. Los cambios en los criterios o ponderaciones no deberán alterar retroactivamente los resultados que fueron generados con una configuración anterior.

El desarrollo deberá respetar las asignaciones docentes, las inscripciones de los alumnos, los periodos escolares y las autorizaciones definidas por los demás módulos.

## 2. Alcance y responsabilidades

El módulo contempla:

- Configurar la evaluación de una materia asignada a un grupo y periodo.
- Definir criterios de evaluación y sus ponderaciones.
- Registrar actividades dentro de los criterios.
- Capturar y consultar calificaciones por alumno y actividad.
- Calcular resultados parciales y finales conforme a la configuración vigente y a su historial.
- Conservar versiones anteriores de las configuraciones.
- Conservar el historial de modificaciones de calificaciones.
- Aplicar las restricciones de captura por vigencia de asignación, fechas límite y cierre del periodo.
- Proporcionar información de calificaciones para consultas y reportes de otros módulos.

La administración de ciclos, grupos, asignaciones docentes y periodos no corresponde a este módulo.

## 3. Contexto de evaluación

Cada materia asignada a un grupo tendrá su propia configuración de evaluación para cada periodo.

La configuración deberá identificar, como mínimo, el contexto al que pertenece:

- Materia asignada.
- Grupo y ciclo escolar correspondientes a esa asignación.
- Periodo escolar.
- Versión de configuración.
- Profesor responsable de la modificación.
- Fecha de creación o modificación.

La relación definitiva entre las tablas de evaluación y las asignaciones deberá revisarse contra el esquema físico aprobado. No se debe asumir que las tablas propuestas ya existen.

## 4. Criterios de evaluación y ponderaciones

La configuración de evaluación estará formada por criterios. Cada criterio tendrá una ponderación dentro de la evaluación del periodo.

Reglas acordadas:

1. La suma de las ponderaciones de los criterios de una configuración debe ser exactamente 100%.
2. Las ponderaciones representan la participación de cada criterio en el resultado.
3. Dentro de un mismo criterio, las actividades tendrán el mismo peso entre sí.
4. El resultado del criterio se obtendrá promediando las calificaciones de sus actividades, de acuerdo con las reglas de cálculo que se implementen.
5. La configuración será específica para la materia, grupo y periodo correspondientes.
6. Una modificación de ponderaciones o criterios generará una nueva versión; no sobrescribirá la versión anterior.

El sistema deberá validar que las ponderaciones sean valores válidos y que su suma cumpla la regla del 100% antes de guardar una configuración.

## 5. Actividades y captura de calificaciones

Las actividades se organizarán dentro de un criterio de evaluación.

Reglas:

- Las actividades pertenecen a una versión de configuración determinada.
- Las actividades creadas antes de un cambio conservarán la relación con la versión en la que fueron registradas.
- Las actividades nuevas utilizarán la nueva versión de configuración.
- Cada calificación deberá corresponder a un alumno, una actividad y el contexto de inscripción pertinente.
- El sistema validará que el puntaje capturado no exceda el valor máximo definido para la actividad.
- Una calificación pendiente se representará como `NULL`; no deberá convertirse automáticamente en cero.
- La captura ordinaria estará limitada por la vigencia de la asignación docente y por las fechas límite y reglas de cierre del periodo.

La regla exacta para tratar actividades sin calificación, actividades no aplicables o alumnos que se incorporen después del inicio del periodo deberá definirse antes de cerrar el algoritmo de cálculo.

## 6. Versionado de configuraciones

Se eligió la opción C para los cambios de configuración: conservar cada versión y mantener separados los resultados generados bajo cada una.

Cuando el profesor modifique los criterios o sus ponderaciones:

1. El sistema conservará la configuración anterior sin sobrescribirla.
2. Se registrará una nueva versión con sus criterios y ponderaciones.
3. Las actividades anteriores permanecerán vinculadas a la versión original.
4. Las actividades nuevas se vincularán a la nueva versión.
5. Las calificaciones ya capturadas conservarán su relación con las actividades y versión correspondientes.
6. El resultado de cada bloque se calculará con las reglas de la versión que lo originó.
7. Los resultados de las versiones se combinarán para obtener la calificación del periodo, aplicando la regla de ponderación temporal que se termine de aprobar.

Cada versión deberá conservar, como mínimo, sus criterios, ponderaciones, fecha de modificación y profesor responsable.

El historial de versiones deberá poder consultarse sin permitir que una edición posterior cambie los resultados históricos.

## 7. Combinación de resultados entre versiones

La decisión funcional contempla combinar los resultados de los bloques de evaluación generados por las distintas versiones, considerando el tiempo durante el cual estuvo vigente cada configuración dentro del periodo.

Como criterio de trabajo se ha planteado distribuir el peso de cada versión de manera proporcional al tiempo de vigencia dentro del periodo. Por ejemplo, si un periodo dura 90 días y una nueva versión entra en vigor después de 80 días, la distribución temporal propuesta sería 80/90 para la primera versión y 10/90 para la segunda.

**Importante:** La fórmula exacta y las reglas de cómputo del tiempo todavía deben confirmarse antes de programarse. En particular, no se debe asumir todavía si se utilizarán días naturales o lectivos, ni cómo se tratarán vacaciones, feriados, el día exacto del cambio o una configuración creada el último día.

También se acordó que una versión anterior sin calificaciones se conserva en el historial, pero su bloque vacío no debe perjudicar al alumno. La regla de normalización de pesos entre versiones que sí tengan resultados deberá quedar expresamente definida y probada antes de implementar el cálculo definitivo.

## 8. Calificaciones pendientes y resultados

Una calificación pendiente se almacenará como `NULL`, no como cero.

El cálculo deberá distinguir entre:

- Una calificación numérica registrada.
- Una actividad pendiente de captura.
- Una actividad que no corresponde al alumno, si esa condición llega a contemplarse.
- Un bloque de configuración sin resultados.

No se deberá asignar un cero automáticamente a una actividad pendiente, porque eso modificaría el resultado del alumno sin que exista una calificación capturada.

La política para determinar cuándo un resultado puede considerarse definitivo, cómo se presenta un periodo con actividades pendientes y cómo se redondea la calificación deberá confirmarse antes de cerrar las reglas de cálculo.

## 9. Historial y corrección de calificaciones

Las modificaciones de calificaciones deberán conservar un historial que permita identificar:

- La calificación anterior.
- La nueva calificación.
- La fecha y hora del cambio.
- El usuario responsable.
- El motivo o referencia de autorización, cuando corresponda.

No se deberán eliminar ni sobrescribir silenciosamente los cambios históricos.

Después de la fecha límite de captura o del cierre del periodo, el profesor no podrá modificar directamente una calificación mediante la captura ordinaria. Deberá utilizar el procedimiento de solicitud de corrección definido por el proyecto.

El módulo de Calificaciones deberá integrarse con el módulo de Solicitudes y Reportes para comprobar que exista autorización antes de permitir una corrección fuera del flujo ordinario.

## 10. Fechas límite y cierre de periodos

Los periodos serán configurados y administrados por el Director. El cierre será manual y la fecha límite de captura deberá bloquear la captura ordinaria aunque el periodo todavía no haya sido cerrado formalmente.

Reglas funcionales:

- La fecha límite bloquea la captura ordinaria.
- El cierre formal del periodo lo realiza el Director.
- Después del cierre, las correcciones se tramitan mediante solicitudes autorizadas.
- Una corrección autorizada no implica reabrir todo el periodo.
- El profesor no deberá poder eludir las restricciones modificando directamente datos o fechas.

La tabla `periodos` y su estructura propuesta no forman parte de las 11 tablas confirmadas en la base de datos descrita por el diccionario. El módulo no debe asumir que ya existe físicamente.

## 11. Relación con alumnos e inscripciones

Las calificaciones deberán asociarse con la inscripción pertinente del alumno en el grupo y contexto académico correspondiente.

Se debe revisar y aprobar la relación exacta antes de diseñar las tablas. Como criterio de diseño pendiente, se ha señalado que podría ser necesario relacionar las calificaciones con una entidad de inscripción en materia, en lugar de utilizar únicamente `id_alumno_grupo`.

Reglas conocidas de inscripción:

- Un cambio de grupo finaliza la inscripción anterior y genera una nueva.
- Las calificaciones anteriores no se transfieren automáticamente a una nueva inscripción.
- Las bajas y reincorporaciones conservan el historial.
- El módulo debe poder consultar las calificaciones históricas asociadas a la inscripción correcta.

No se debe asumir que existe una tabla de inscripción en materia: no forma parte de las 11 tablas confirmadas.

## 12. Asignaciones docentes y permisos

El profesor podrá administrar la evaluación únicamente dentro de las materias y grupos que tenga asignados y conforme a la vigencia de esas asignaciones.

- Las asignaciones activas permiten las operaciones ordinarias autorizadas.
- Las asignaciones terminadas mantienen disponible la consulta histórica.
- Una asignación terminada no permite nuevas capturas ordinarias.
- Las correcciones posteriores se procesan mediante el flujo de autorización correspondiente.
- El módulo no administra ni modifica las asignaciones docentes.

Las validaciones deberán realizarse en la capa de servicio y no depender únicamente de que la interfaz oculte botones.

## 13. Entidades propuestas y estado de la base de datos

Las siguientes tablas son propuestas funcionales para el módulo y **no forman parte de las 11 tablas confirmadas**:

- `periodos`
- `configuraciones_evaluacion`
- `criterios_evaluacion`
- `actividades`
- `calificaciones`
- `historial_calificaciones`

Podrían requerirse entidades adicionales o ajustes de relaciones, por ejemplo para representar la inscripción de un alumno en una materia. Cualquier necesidad de este tipo deberá presentarse al responsable de arquitectura y base de datos.

No se deberán crear tablas, campos, índices, claves foráneas ni restricciones por iniciativa individual sin revisión y aprobación.

## 14. Validaciones mínimas

La implementación deberá contemplar, como mínimo:

- Que el profesor autenticado tenga una asignación válida para la materia y el grupo.
- Que el periodo corresponda al ciclo y nivel aplicables.
- Que la configuración pertenezca a la materia, grupo y periodo correctos.
- Que la suma de ponderaciones de cada versión sea 100%.
- Que cada actividad pertenezca a un criterio y versión válidos.
- Que el puntaje no exceda el máximo de la actividad.
- Que la calificación corresponda a la inscripción académica correcta.
- Que `NULL` se trate como pendiente y no como cero.
- Que las versiones históricas no sean sobrescritas.
- Que la captura ordinaria respete fechas límite y cierres.
- Que una corrección posterior al límite tenga la autorización correspondiente.
- Que toda modificación conserve el historial y al responsable.

Las operaciones que involucren varias entidades deberán ejecutarse de manera transaccional cuando sea necesario para evitar registros parciales o inconsistentes.

## 15. Integración técnica

El módulo deberá respetar la arquitectura general del proyecto:

- Java y JavaFX para la aplicación.
- FXML para las vistas.
- MVC para separar interfaz, controladores y lógica.
- DAO para acceso a datos.
- Service para reglas de negocio y cálculos.
- MySQL como base de datos.
- Conexión JDBC compartida del proyecto.

El desarrollo deberá:

- Reutilizar la configuración Maven y dependencias existentes.
- Reutilizar componentes compartidos de interfaz y conexión.
- Mantener las clases dentro de la estructura de paquetes acordada.
- Evitar conexiones JDBC independientes.
- Evitar cambios unilaterales a archivos globales o al esquema de la base de datos.
- Coordinar la integración con los demás módulos y ramas del repositorio.

## 16. Entregables esperados

1. Vistas para consultar la evaluación de una materia, grupo y periodo.
2. Interfaz para crear y modificar configuraciones mediante nuevas versiones.
3. Interfaz para administrar criterios y ponderaciones.
4. Interfaz para registrar actividades por criterio.
5. Interfaz para capturar y consultar calificaciones.
6. Presentación de resultados parciales y finales.
7. Consulta del historial de configuraciones y modificaciones.
8. Clases DAO y Service correspondientes.
9. Validaciones, transacciones y manejo de errores.
10. Pruebas del cálculo, versionado, pendientes y restricciones de captura.
11. Documentación de las reglas y de la integración.

La distribución definitiva de vistas, controladores, servicios y DAO deberá ajustarse al código real del proyecto.

## 17. Pendientes antes de cerrar las reglas de cálculo

Antes de implementar el cálculo definitivo, deberán resolverse expresamente:

- Días naturales frente a días lectivos para calcular la vigencia de cada versión.
- Tratamiento de vacaciones, feriados y días sin actividad académica.
- Inclusividad de la fecha de inicio y de la fecha del cambio de versión.
- Tratamiento de una nueva versión creada el último día del periodo.
- Fórmula exacta para normalizar los pesos cuando una versión no tenga calificaciones.
- Tratamiento de actividades pendientes al calcular resultados parciales y finales.
- Regla de redondeo y precisión de las calificaciones.
- Relación definitiva entre calificaciones, alumnos, inscripciones, materias asignadas y periodos.
- Reglas de cierre y de corrección autorizada coordinadas con el módulo correspondiente.

Estos puntos deberán revisarse antes de convertirlos en código. Las propuestas de este documento no sustituyen una aprobación de arquitectura ni una decisión funcional pendiente.

---

**Nota de implementación:** Este documento describe el alcance funcional y las decisiones de versionado ya acordadas. Las tablas del módulo de Calificaciones y Periodos siguen siendo propuestas pendientes de aprobación e implementación. Antes de escribir consultas SQL, se deberá contrastar el diseño con el diccionario de datos vigente y con la estructura física real de MySQL.
