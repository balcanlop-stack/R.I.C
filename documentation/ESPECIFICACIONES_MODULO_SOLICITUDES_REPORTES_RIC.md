# R.I.C. — Especificaciones del módulo de Solicitudes y Reportes

**Versión:** 1.1  
**Estado:** Borrador actualizado para revisión  
**Fecha:** 25 de noviembre de 2026  
**Proyecto:** Registro Integral de Calificaciones (R.I.C.)

---

## 1. Propósito del módulo

El módulo de Solicitudes y Reportes permitirá gestionar las solicitudes de autorización para corregir calificaciones después de la fecha límite de captura o del cierre de un periodo, así como consultar y presentar información académica mediante reportes.

El módulo deberá asegurar que las correcciones posteriores al flujo ordinario sean autorizadas por el Director, que cada decisión quede registrada y que el periodo no tenga que reabrirse para corregir una calificación específica.

También permitirá que el Director y el profesor consulten las solicitudes que les correspondan y reciban notificaciones internas sobre sus cambios de estado.

## 2. Alcance y responsabilidades

El módulo contempla:

- Administrar el flujo de solicitudes, autorizaciones, extensiones, vencimientos, estados e historial.
- Crear solicitudes de corrección de calificaciones.
- Incluir varias calificaciones dentro de una misma solicitud.
- Revisar y resolver individualmente cada detalle de una solicitud.
- Aprobar o rechazar solicitudes y registrar la decisión.
- Permitir que el profesor capture el nuevo valor cuando la corrección haya sido autorizada.
- Controlar el plazo concedido para realizar la corrección.
- Gestionar solicitudes de extensión del plazo.
- Marcar como vencidas las autorizaciones cuyo plazo terminó sin completarse.
- Consultar el historial de solicitudes y sus decisiones.
- Generar o facilitar reportes académicos a partir de información disponible en los módulos correspondientes.
- Gestionar notificaciones internas relacionadas con solicitudes y autorizaciones.

La configuración de periodos, la asignación de profesores y la captura ordinaria de calificaciones pertenecen a otros módulos.

La distribución de responsabilidades entre módulos queda establecida así:

- **Solicitudes y Reportes:** administra el flujo, estados, plazos, extensiones, vencimientos, historial y notificaciones de solicitudes.
- **Director:** revisa y decide la aprobación o el rechazo de cada detalle y resuelve las solicitudes de extensión desde las pantallas del módulo Director.
- **Profesor:** crea solicitudes, consulta su estado y captura el nuevo valor cuando una corrección ha sido autorizada y sigue vigente.
- **Calificaciones:** valida la autorización, ejecuta la modificación de la calificación y conserva su historial.

El módulo Solicitudes y Reportes no debe implementar pantallas o acciones que sustituyan las responsabilidades de decisión del módulo Director, ni modificar directamente el valor de una calificación.

## 3. Participantes y responsabilidades

### 3.1 Profesor

El profesor podrá:

- Crear una solicitud de corrección para una o varias calificaciones.
- Seleccionar las calificaciones que requieren corrección.
- Explicar el error que necesita corregir.
- Consultar el estado de cada detalle de la solicitud.
- Capturar el nuevo valor de una calificación cuando el Director haya autorizado esa corrección.
- Solicitar una extensión antes de que venza el plazo autorizado.
- Consultar las solicitudes y autorizaciones relacionadas con sus asignaciones, incluso si la asignación docente terminó.

La sustitución de un profesor o el fin de una asignación no elimina ni cancela automáticamente las solicitudes pendientes. El profesor conserva acceso de consulta a las solicitudes relacionadas con sus asignaciones anteriores. Una corrección autorizada podrá completarse aunque la asignación haya terminado, siempre que la autorización siga vigente y se limite al detalle aprobado.

El profesor no propondrá el nuevo valor dentro de la solicitud inicial. La solicitud identifica la calificación y explica el error; si se autoriza, el profesor captura el nuevo valor dentro del plazo concedido.

### 3.2 Director

El módulo Director proporciona las pantallas y acciones para que el Director revise y decida las solicitudes. El módulo Solicitudes y Reportes administra el flujo y conserva el seguimiento de esas decisiones.

El Director podrá:

- Consultar las solicitudes recibidas.
- Revisar cada calificación incluida en una solicitud.
- Aprobar o rechazar cada detalle individualmente.
- Establecer el límite temporal para realizar una corrección autorizada.
- Aprobar o rechazar solicitudes de extensión.
- Consultar el historial y el estado de las solicitudes.
- Consultar reportes académicos conforme a sus permisos.

La autorización de una corrección específica no reabre el periodo completo ni habilita la modificación de otras calificaciones.

## 4. Creación de solicitudes de corrección

Una solicitud podrá contener varias calificaciones, conforme a la opción B acordada.

Reglas:

1. El profesor selecciona las calificaciones que necesita corregir.
2. Para cada calificación seleccionada, explica el error que motiva la solicitud.
3. El profesor no captura ni propone el nuevo valor en la solicitud inicial.
4. El sistema conserva la identidad del profesor solicitante y la fecha y hora de creación.
5. Cada calificación se revisa y resuelve individualmente, aunque forme parte de una misma solicitud.
6. La solicitud debe conservar sus detalles y decisiones como historial.

La solicitud deberá referenciar las calificaciones existentes, no crear copias independientes de ellas.

La referencia debe conservar el contexto académico de la calificación: inscripción del alumno, actividad evaluada y relaciones que permitan identificar grupo, materia, periodo y asignación docente pertinentes. No se debe identificar una calificación únicamente mediante `id_alumno`. La estructura física exacta de estas relaciones deberá aprobarse con el responsable de arquitectura y base de datos.

## 5. Revisión y resolución individual

El Director revisará cada detalle de la solicitud de forma independiente.

Para cada calificación podrá:

- APROBAR la corrección.
- RECHAZAR la corrección.

La decisión deberá conservar al menos el responsable, la fecha y hora y, cuando corresponda, la justificación de la decisión.

Una solicitud con varios detalles puede terminar con resultados diferentes: algunos aprobados y otros rechazados. El sistema no deberá tratar todos los detalles como aprobados o rechazados en bloque si el Director los resolvió individualmente.

## 6. Estados de los detalles de solicitud

Los estados definidos para cada detalle son:

| Estado | Significado |
|---|---|
| PENDIENTE | El Director todavía no ha resuelto el detalle. |
| APROBADA | El Director autorizó la corrección y el profesor puede capturar el nuevo valor dentro del plazo. |
| RECHAZADA | El Director no autorizó la corrección. |
| COMPLETADA | El profesor realizó la corrección autorizada. |
| VENCIDA | Terminó el plazo concedido sin que la corrección se completara. |

El estado deberá reflejar el avance real de cada detalle. La solicitud principal podrá mostrar un resumen derivado de sus detalles, pero la resolución y el seguimiento se realizarán individualmente.

## 7. Captura de la corrección autorizada

Cuando un detalle sea aprobado:

1. El sistema registra la autorización del Director.
2. El Director establece un límite temporal para realizar la corrección.
3. El profesor recibe una notificación interna.
4. El profesor captura el nuevo valor de la calificación autorizada.
5. El sistema valida que la autorización siga vigente y corresponda a esa calificación.
6. Al completar la operación, el detalle pasa a estado COMPLETADA.
7. Se conserva el valor anterior, el nuevo valor, el responsable y la fecha y hora de la modificación.

La autorización se limita a la calificación indicada. No permite modificar otras calificaciones ni reabrir el periodo.

## 8. Plazo y vencimiento de autorizaciones

El Director fija el límite temporal para realizar cada corrección autorizada.

Reglas:

- El profesor debe completar la corrección antes de que venza el plazo.
- El sistema debe impedir que se complete una autorización vencida.
- Si el plazo termina sin que se realice la corrección, el detalle pasa a estado VENCIDA.
- La autorización vencida no se reactiva mediante una extensión posterior.
- Si todavía se necesita corregir la calificación, el profesor deberá generar una nueva solicitud.

El mecanismo técnico para detectar y actualizar autorizaciones vencidas deberá definirse e integrarse con la arquitectura del sistema.

## 9. Solicitudes de extensión

El profesor podrá solicitar una extensión únicamente antes de que venza el plazo de una autorización aprobada.

Reglas:

1. La solicitud de extensión debe realizarse antes del vencimiento.
2. El Director podrá aprobarla o rechazarla.
3. Si se aprueba, se actualizará el límite temporal conforme a la decisión del Director y se conservará el historial del plazo anterior.
4. Si se rechaza, se mantiene el límite original.
5. No se permite solicitar una extensión después del vencimiento.
6. Una autorización vencida requiere una nueva solicitud de corrección si el profesor todavía necesita realizar el cambio.

La extensión no debe borrar ni sobrescribir el plazo original: ambos deben poder consultarse en el historial.

## 10. Asignaciones docentes terminadas

Las solicitudes y autorizaciones deben conservarse aunque la asignación del profesor haya terminado.

Esta regla también aplica cuando un profesor es sustituido: la asignación anterior se finaliza y se crea una nueva asignación para el sustituto. Las solicitudes pendientes siguen asociadas al profesor y a la asignación originales; no se trasladan al sustituto ni cambian su autoría. El Director puede resolverlas y autorizar correcciones específicas sin reactivar la asignación anterior.

Reglas:

- El profesor podrá consultar las solicitudes relacionadas con sus asignaciones anteriores.
- El Director podrá revisar y resolver solicitudes pendientes aunque la asignación haya finalizado.
- Una autorización específica podrá permitir la corrección aunque la asignación ya no esté activa, siempre que se encuentre vigente y haya sido aprobada por el Director.
- La autorización no reactiva la asignación docente ni permite nuevas capturas ordinarias.
- El acceso del profesor se limita a las calificaciones y detalles expresamente autorizados.

## 11. Notificaciones internas

El sistema utilizará notificaciones internas; no se contempla el envío de correos externos.

### 11.1 Notificaciones para el Director

El Director deberá recibir notificaciones cuando:

- Se registre una nueva solicitud de corrección.
- Se registre una solicitud de extensión.

### 11.2 Notificaciones para el profesor

El profesor deberá recibir notificaciones cuando:

- Una solicitud o uno de sus detalles sea aprobado o rechazado.
- Se establezca el límite temporal de una corrección autorizada.
- Una solicitud de extensión sea aprobada o rechazada.
- Una autorización se venza.

### 11.3 Reglas generales

- Las notificaciones relacionadas con una misma solicitud deberán agruparse o mantenerse vinculadas a ella.
- Una actualización nueva deberá marcarse como no leída para el destinatario correspondiente.
- La notificación deberá permitir identificar el evento y la solicitud o detalle relacionado.
- El historial de solicitudes seguirá siendo la fuente principal para conocer las decisiones; la notificación solo informa del cambio.

La estructura física de las notificaciones deberá revisarse con el responsable de arquitectura y base de datos.

## 12. Reportes

El módulo facilitará la consulta y presentación de información académica autorizada.

Los reportes deberán basarse en datos registrados por los módulos responsables, sin duplicar ni alterar sus fuentes.

Como alcance funcional general, se contempla consultar información relacionada con:

- Calificaciones por alumno, grupo, materia y periodo.
- Resultados académicos por grupo y materia.
- Historial de correcciones de calificaciones.
- Solicitudes de corrección y sus estados.
- Autorizaciones, extensiones y vencimientos.
- Información histórica asociada a asignaciones docentes terminadas.

El catálogo definitivo de reportes, sus filtros, formatos de exportación y permisos deberá definirse con el responsable del proyecto antes de implementar cada reporte. No se deben asumir reportes, métricas o formatos específicos que todavía no hayan sido aprobados.

## 13. Entidades propuestas y estado de la base de datos

Las siguientes tablas son propuestas funcionales y **no forman parte de las 11 tablas confirmadas** en el esquema documentado:

- `solicitudes_correccion`
- `detalles_solicitud_correccion`
- `extensiones_autorizacion`

También se requiere definir la estructura de las notificaciones internas y confirmar las relaciones con las entidades de calificaciones e historial.

El módulo deberá consultar las tablas de calificaciones y demás entidades que se aprueben para el módulo de Calificaciones. No debe asumir que ya existen físicamente.

No se deberán crear tablas, campos, claves, índices, restricciones ni relaciones sin revisión y autorización del responsable de arquitectura y base de datos.

## 14. Validaciones mínimas

La implementación deberá validar, como mínimo:

- Que el profesor autenticado sea el responsable de la calificación que solicita corregir, conforme a las reglas de asignación e historial.
- Que la calificación seleccionada exista y corresponda al contexto académico indicado.
- Que la solicitud incluya una explicación del error.
- Que el profesor no proponga el nuevo valor en la solicitud inicial.
- Que cada detalle sea resuelto individualmente por el Director.
- Que solo un detalle aprobado y vigente permita capturar una corrección.
- Que la corrección se limite a la calificación autorizada.
- Que la captura se realice antes del límite temporal.
- Que una extensión se solicite antes del vencimiento.
- Que una autorización vencida no pueda reactivarse mediante extensión.
- Que se conserve el historial de valores, decisiones, plazos y responsables.
- Que una asignación terminada no se reactive por el hecho de existir una autorización específica.

Las operaciones que actualicen calificaciones y estados de solicitudes deberán ejecutarse de manera transaccional cuando corresponda, para evitar que la calificación cambie sin que el detalle quede marcado correctamente como completado, o viceversa.

## 15. Integración con los demás módulos

### 15.1 Módulo de Calificaciones

- Proporciona las calificaciones que pueden ser seleccionadas en una solicitud.
- Aplica las reglas de captura ordinaria y de cálculo.
- Recibe la corrección autorizada y conserva el historial del valor.
- No deberá permitir que el flujo de solicitudes modifique calificaciones sin autorización válida.

### 15.2 Módulo Director

- Administra los periodos y sus fechas límite y cierres.
- Recibe, revisa y resuelve las solicitudes.
- Define los plazos de las correcciones autorizadas.
- Resuelve las solicitudes de extensión.
- Consulta los reportes que correspondan a sus permisos.

### 15.3 Módulo Profesor y Asistencia

- Proporciona el contexto de las asignaciones docentes y su vigencia.
- Permite identificar al profesor responsable.
- Conserva la consulta histórica cuando una asignación termina.
- No habilita nuevas capturas ordinarias por existir una solicitud o autorización.

## 16. Integración técnica

El módulo deberá respetar la arquitectura general del proyecto:

- Java y JavaFX para la aplicación.
- FXML para las vistas.
- MVC para separar interfaz, controladores y lógica.
- DAO para el acceso a datos.
- Service para reglas de negocio y validaciones.
- MySQL como base de datos.
- Conexión JDBC compartida del proyecto.

El desarrollo deberá:

- Reutilizar la configuración Maven y dependencias existentes.
- Reutilizar componentes comunes de interfaz y conexión.
- Mantener las clases dentro de la estructura de paquetes acordada.
- Evitar conexiones JDBC independientes.
- Evitar cambios unilaterales a archivos globales o al esquema de la base de datos.
- Coordinar la integración con los demás módulos y ramas del repositorio.

## 17. Entregables esperados

1. Vista para que el profesor consulte y cree solicitudes de corrección.
2. Interfaz para seleccionar varias calificaciones y describir cada error.
3. Vista para que el Director revise los detalles individualmente.
4. Funciones para aprobar o rechazar cada detalle.
5. Interfaz para que el profesor capture una corrección autorizada.
6. Gestión de plazos, vencimientos y solicitudes de extensión.
7. Consulta del historial de solicitudes y decisiones.
8. Notificaciones internas para profesores y Director.
9. Vistas o componentes de reportes aprobados.
10. Clases DAO y Service correspondientes.
11. Validaciones, transacciones y manejo de errores.
12. Pruebas de solicitudes con varios detalles, decisiones mixtas, vencimientos y extensiones.
13. Documentación de integración.

La distribución definitiva de vistas, controladores, servicios y DAO deberá ajustarse a la estructura real del proyecto.

## 18. Pendientes antes de cerrar la especificación

Los siguientes puntos requieren definición antes de implementar:

- Catálogo definitivo de reportes, filtros, permisos y formatos de exportación.
- Estructura física de notificaciones internas.
- Estructura definitiva de las tablas de solicitudes, detalles y extensiones.
- Relación exacta entre solicitudes, calificaciones, actividades, versiones de evaluación, inscripciones y asignaciones docentes.
- Regla técnica y frecuencia para detectar autorizaciones vencidas.
- Si el plazo se establece por detalle o se comparte entre los detalles aprobados de una solicitud, cuando existan varias autorizaciones.
- Información obligatoria que deberá incluir la justificación de rechazo o aprobación, más allá de los datos mínimos de auditoría.
- Reglas de retención y consulta histórica, en coordinación con las políticas generales del sistema.

Estos puntos no deberán resolverse mediante cambios unilaterales en la base de datos ni mediante supuestos en el código. Se deberán presentar para revisión y aprobación.

---

**Nota de implementación:** Este documento describe el flujo funcional acordado para solicitudes de corrección, autorizaciones, extensiones y notificaciones internas. Las tablas propuestas siguen pendientes de aprobación e implementación. Antes de desarrollar consultas SQL, se deberá contrastar el diseño con el diccionario de datos vigente y con la estructura física real de MySQL.


## 19. Reglas de continuidad académica relacionadas con solicitudes

Las solicitudes de corrección deben respetar el contexto histórico de los registros académicos y no alterar las reglas de inscripción, evaluación o asignación docente.

### 19.1 Cambio de grupo y reincorporación del alumno

- Las calificaciones anteriores permanecen asociadas a la inscripción original del alumno.
- Un cambio de grupo o una reincorporación genera una nueva inscripción; las calificaciones de inscripciones diferentes no se combinan.
- Una solicitud de corrección debe referenciar la calificación histórica concreta y su inscripción original.
- La autorización de una corrección no transfiere la calificación a otra inscripción ni modifica el grupo al que pertenecía.
- El Director puede revisar y resolver una solicitud pendiente aunque el alumno ya no esté inscrito en el grupo original, siempre que la solicitud corresponda a un registro válido y conserve su contexto histórico.

### 19.2 Sustitución de profesor

- Las actividades y calificaciones conservan la autoría y asignación docente originales.
- Una solicitud creada por el profesor responsable de la calificación permanece vinculada a ese profesor y a su asignación original.
- La sustitución no cancela solicitudes ni cambia al solicitante.
- El Director puede resolver una solicitud pendiente después de que la asignación haya terminado.
- El profesor podrá completar una corrección autorizada y vigente aun cuando la asignación haya terminado; esto no reactiva la asignación ni habilita nuevas capturas ordinarias.
- El módulo de Calificaciones es responsable de ejecutar el cambio autorizado y conservar el valor anterior, el nuevo valor, el responsable y la fecha y hora.

### 19.3 Configuración de evaluación

La configuración pertenece a la combinación de materia, grupo y periodo. No pertenece exclusivamente al profesor o a la asignación docente. Una sustitución de profesor no crea una nueva versión de configuración.

Las solicitudes de corrección deben apuntar a la calificación que efectivamente se registró bajo su contexto original. El proceso de autorización no debe recalcular ni trasladar resultados entre versiones de configuración, inscripciones o grupos.

## 20. Límites de implementación y coordinación

El responsable del módulo Solicitudes y Reportes no debe:

- Modificar directamente calificaciones; debe solicitar la ejecución de la corrección autorizada al módulo de Calificaciones mediante el contrato de integración acordado.
- Implementar la decisión del Director como una lógica paralela o duplicada dentro de este módulo.
- Crear o modificar tablas, campos, índices, claves o relaciones sin aprobación del responsable de arquitectura y base de datos.
- Asumir que las tablas propuestas en este documento ya existen físicamente.
- Cambiar la autoría o asignación histórica de actividades, calificaciones o solicitudes.
- Reabrir periodos completos para permitir correcciones individuales.
- Permitir que una autorización vencida se reactive mediante una extensión posterior.

Cualquier campo, relación o entidad adicional que se considere necesaria deberá documentarse y presentarse al responsable de arquitectura y base de datos antes de implementarse.
