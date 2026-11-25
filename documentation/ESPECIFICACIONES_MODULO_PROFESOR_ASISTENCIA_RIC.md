# R.I.C. — Especificaciones del módulo Profesor y Asistencia

**Versión:** 1.1  
**Estado:** Borrador actualizado para revisión  
**Fecha:** 25 de noviembre de 2026  
**Proyecto:** Registro Integral de Calificaciones (R.I.C.)

---

## 1. Propósito del módulo

El módulo Profesor y Asistencia permitirá que el profesor consulte sus grupos y materias asignados, gestione la información académica correspondiente a esas asignaciones y registre la asistencia de los alumnos.

El módulo deberá respetar las asignaciones docentes administradas por el Director y conservar el historial de la actividad académica. No deberá modificar por cuenta propia la estructura de la base de datos ni las reglas generales del sistema.

## 2. Alcance y responsabilidades

El módulo contempla las siguientes funciones:

- Acceso del profesor mediante su cuenta de usuario.
- Consulta de grupos y materias que tiene asignados.
- Consulta de alumnos inscritos en cada grupo.
- Selección de materias dentro de los grupos asignados, conforme a las reglas del sistema.
- Registro de asistencia por materia, grupo y fecha.
- Consulta de registros de asistencia anteriores.
- Modificación de registros de asistencia cuando esté permitido, conservando el historial.
- Consulta de sus asignaciones terminadas y de la información académica histórica asociada.

Las funciones de captura y modificación estarán sujetas al estado y vigencia de la asignación docente, al periodo correspondiente y a las autorizaciones aplicables.

## 3. Acceso y datos del profesor

El acceso se realizará mediante las credenciales administradas por el sistema. La identidad del profesor deberá relacionarse con su registro en `profesores` y con su cuenta en `usuarios`.

Reglas acordadas:

- El Director crea el perfil y las credenciales iniciales del profesor.
- El profesor puede cambiar su contraseña.
- Si un profesor deja la institución, su cuenta se desactiva; no se elimina físicamente.
- No se deberá desactivar una cuenta mientras el profesor tenga asignaciones activas o programadas pendientes.
- El módulo no deberá crear conexiones JDBC independientes. Utilizará la conexión y los componentes compartidos del proyecto.

## 4. Consulta de grupos y materias asignados

El profesor podrá consultar los grupos que tenga asignados y las materias que correspondan a cada asignación.

La información deberá obtenerse de las entidades existentes:

- `asignaciones_docentes`
- `materias`
- `materias_asignadas`
- `grupos`
- `grados`
- `ciclos_escolares`
- `alumnos`
- `alumnos_grupos`

Reglas funcionales:

1. Un profesor puede tener varios grupos asignados.
2. Un grupo puede tener varios profesores asignados.
3. El Director administra las asignaciones de grupos a profesores.
4. El profesor selecciona las materias que impartirá dentro de los grupos que tiene asignados.
5. Una materia no puede repetirse dentro del mismo grupo mientras exista una asignación vigente, aunque la impartan profesores distintos.
6. La misma materia puede asignarse en grupos diferentes.
7. Cuando termina la asignación de una materia para un profesor, otro profesor puede impartir posteriormente esa misma materia al mismo grupo mediante una nueva asignación. La asignación anterior debe conservarse como historial.
8. La configuración de evaluación corresponde a la combinación de materia, grupo y periodo; no pertenece exclusivamente al profesor ni a su asignación.
9. Una materia no puede repetirse dentro del mismo grupo mientras exista una asignación vigente, independientemente del profesor que la imparta.

El módulo Profesor no debe crear, editar ni cancelar asignaciones docentes de grupo que son responsabilidad del Director. La selección y asignación de materias deberá respetar las reglas y validaciones compartidas del sistema.

## 5. Estados y vigencia de las asignaciones

Los estados definidos para `asignaciones_docentes` y `materias_asignadas` son:

| Valor | Estado |
|---|---|
| 1 | PROGRAMADA |
| 2 | ACTIVA |
| 3 | INACTIVA |
| 4 | CANCELADA |

Reglas:

- Las asignaciones programadas se activarán automáticamente al llegar su fecha de inicio. El mecanismo técnico que realizará esta activación deberá definirse e integrarse en la arquitectura del sistema.
- Una asignación programada puede cancelarse antes de iniciar. Deben conservarse el estado CANCELADA, la fecha y el responsable de la cancelación.
- Se permite finalizar anticipadamente una asignación, registrando el motivo y conservando el historial.
- Mientras una asignación esté vigente, el profesor podrá realizar las operaciones ordinarias permitidas por el sistema.
- Al terminar una asignación, el profesor conservará acceso de consulta a sus calificaciones, actividades, criterios, asistencias, modificaciones y solicitudes relacionadas.
- Una asignación terminada no deberá permitir nuevas capturas ordinarias. Las correcciones posteriores deberán seguir el procedimiento de autorización correspondiente.
- El profesor conserva acceso de consulta a las actividades y calificaciones que registró durante su asignación, aunque posteriormente sea sustituido.

## 6. Consulta de alumnos

El profesor podrá consultar los alumnos inscritos en los grupos que tenga asignados.

La consulta deberá considerar el historial de inscripciones de `alumnos_grupos` y no asumir que todo alumno registrado en `alumnos` pertenece actualmente al grupo.

Reglas relacionadas con las inscripciones:

- Una inscripción activa se identifica con estado 1; una inscripción finalizada, con estado 0.
- Un cambio de grupo finaliza la inscripción anterior y crea una nueva. No se modifica la inscripción histórica para simular el cambio.
- Las calificaciones y asistencias anteriores no se transfieren automáticamente a la nueva inscripción.
- Las bajas y reincorporaciones conservan el historial; una reincorporación genera una nueva inscripción.
- El módulo debe consultar la inscripción correspondiente a la fecha y al contexto académico del registro, evitando atribuir asistencia a una inscripción incorrecta.
- Las asistencias anteriores permanecen asociadas a la inscripción original. No se transfieren a una inscripción nueva por cambio de grupo, baja temporal o reincorporación.
- Para registrar o consultar asistencia, se debe verificar que la inscripción del alumno corresponda al grupo y a la fecha de la sesión.

El módulo Profesor no podrá dar de alta alumnos, cambiar alumnos de grupo ni modificar sus datos personales, salvo que una especificación posterior autorice expresamente alguna función.

## 7. Registro de asistencia

La asistencia se registrará por **materia asignada, grupo y fecha**.

Estados de asistencia definidos:

- PRESENTE
- AUSENTE
- RETARDO
- JUSTIFICADO

Reglas funcionales:

1. El profesor registra la asistencia de los alumnos que correspondan a la materia y grupo seleccionados.
2. El profesor puede marcar una asistencia como JUSTIFICADO.
3. Se permitirá el registro retroactivo dentro del periodo o plazo que establezca el sistema.
4. Deben distinguirse la fecha de la sesión y la fecha y hora reales en que se capturó el registro.
5. Las modificaciones de asistencia deberán conservar un historial.
6. Los registros no se eliminarán por el hecho de que un alumno cause baja o cambie de grupo.
7. La consulta histórica deberá permitir identificar qué se registró y cuándo se realizó la captura o modificación.
8. La asistencia se conservará vinculada a la inscripción del alumno que corresponda a la fecha de la sesión; no se debe asociar automáticamente a inscripciones posteriores.
9. Si el alumno se incorpora a un grupo después de iniciada la evaluación, no se deben generar asistencias para sesiones anteriores a su fecha de incorporación.
10. Si el alumno cambia de grupo o se reincorpora, el profesor consultará y registrará asistencia conforme a la nueva inscripción desde su fecha de vigencia.

La asistencia no deberá registrarse para una materia o grupo que no corresponda a una asignación válida del profesor.

## 8. Modificación e historial de asistencia

Cuando una modificación esté permitida, el sistema deberá conservar información suficiente para reconstruir el cambio, incluyendo al menos el valor anterior y el nuevo, la fecha y hora de la modificación y el usuario responsable.

El detalle definitivo de los campos y de las entidades de historial deberá acordarse con el responsable de arquitectura y base de datos antes de implementar el esquema.

No se deberá sobrescribir silenciosamente un registro histórico ni eliminarlo para corregir un error.

## 9. Relación con periodos y límites de captura

El registro retroactivo de asistencia estará sujeto a los límites temporales que se definan para el periodo académico correspondiente.

El proyecto contempla periodos configurables por nivel y ciclo escolar, así como fechas límite y cierres administrados por el Director. La entidad `periodos` todavía no forma parte de las 11 tablas confirmadas en la base de datos descrita en el diccionario.

Por lo tanto:

- El módulo no debe asumir que la tabla `periodos` ya existe físicamente.
- La regla exacta para permitir o bloquear capturas de asistencia deberá integrarse cuando se apruebe y construya la estructura correspondiente.
- No se deben inventar fechas límite ni reglas de días lectivos que todavía no hayan sido definidas.

## 10. Relación con el módulo de Calificaciones y otros módulos

El módulo Profesor y Asistencia debe integrarse con el módulo de Calificaciones sin duplicar sus responsabilidades.

- La consulta de grupos, materias y alumnos deberá utilizar las mismas entidades compartidas.
- El registro de asistencia conservará su propio historial.
- Las actividades, criterios y calificaciones serán responsabilidad funcional del módulo de Calificaciones.
- Las solicitudes de corrección y sus autorizaciones serán responsabilidad del módulo de Solicitudes y Reportes y del Director, según las reglas aprobadas.
- El módulo Profesor deberá mostrar la información histórica que le corresponda, incluso cuando una asignación haya terminado, sin habilitar por ello nuevas capturas ordinarias.

## 11. Entidades existentes y pendientes

### 11.1 Entidades existentes en la base de datos confirmada

La base de datos confirmada contiene estas entidades relevantes para el módulo:

- `usuarios`
- `profesores`
- `ciclos_escolares`
- `grados`
- `grupos`
- `alumnos`
- `alumnos_grupos`
- `asignaciones_docentes`
- `materias`
- `materias_asignadas`

Estas entidades forman parte del esquema existente; el módulo deberá ajustarse a sus nombres, campos y relaciones documentados en el diccionario de datos.

### 11.2 Estructura de asistencia pendiente

Las siguientes tablas son propuestas funcionales, pero **no forman parte de las 11 tablas confirmadas**:

- `asistencias`
- `detalle_asistencia`
- `historial_asistencias`

Su diseño físico, campos, claves, restricciones e índices deberán revisarse y aprobarse con el responsable de arquitectura y base de datos antes de crear cualquier tabla o modificar el esquema.

Tampoco se debe asumir que las entidades propuestas para periodos ya existen físicamente.

## 12. Reglas de validación

Como mínimo, la implementación deberá validar:

- Que el profesor autenticado corresponda a una cuenta válida y activa.
- Que el grupo y la materia estén relacionados con una asignación del profesor.
- Que la asignación se encuentre en un estado y dentro de una vigencia que permitan la operación solicitada.
- Que el alumno tenga la inscripción que corresponda al grupo y a la fecha de la sesión.
- Que la sesión no sea anterior a la fecha de inicio de la inscripción considerada.
- Que el estado de asistencia pertenezca al catálogo acordado.
- Que la captura retroactiva respete el plazo aplicable, una vez que este se encuentre definido.
- Que toda modificación conserve el historial y al usuario responsable.
- Que una asignación terminada no habilite nuevas capturas ordinarias.

Las reglas que involucran varias tablas deberán validarse en la capa de servicio y, cuando corresponda, dentro de transacciones para evitar inconsistencias.

## 13. Integración técnica

El desarrollo deberá respetar la arquitectura general del proyecto:

- Java y JavaFX para la aplicación.
- FXML para las vistas.
- MVC para separar interfaz, controladores y lógica.
- DAO para el acceso a datos.
- Service para las reglas de negocio y validaciones.
- MySQL como base de datos.
- La conexión JDBC compartida del proyecto.

El módulo deberá:

- Reutilizar la configuración de Maven y las dependencias existentes.
- Reutilizar los componentes comunes de interfaz y conexión.
- Mantener sus clases dentro de la estructura de paquetes acordada para el proyecto.
- Evitar modificar archivos globales, tablas o relaciones sin autorización.
- Coordinar los cambios de integración con la rama principal y con los responsables de los otros módulos.

## 14. Entregables esperados

El módulo deberá contemplar, de acuerdo con la estructura definitiva del proyecto:

1. Vistas para consultar grupos y materias asignados.
2. Vista para consultar alumnos de un grupo.
3. Interfaz para registrar asistencia por materia, grupo y fecha.
4. Interfaz para consultar registros históricos de asistencia.
5. Funciones de modificación sujetas a las reglas y permisos aprobados.
6. Clases DAO y Service correspondientes.
7. Validaciones y manejo de errores.
8. Pruebas de los casos ordinarios, históricos y de restricciones.
9. Documentación de integración y de cualquier requisito adicional detectado.

La distribución exacta de pantallas, clases y paquetes se definirá al revisar la estructura real del proyecto, evitando duplicar componentes que ya existan.

## 15. Pendientes antes de cerrar la especificación

Los siguientes puntos requieren definición o aprobación antes de convertirse en reglas técnicas definitivas:

- El plazo exacto permitido para capturar asistencia retroactiva.
- Si dicho plazo se calcula en días naturales o lectivos y cómo se tratan vacaciones y días no laborables.
- La estructura física definitiva de `asistencias`, `detalle_asistencia` e `historial_asistencias`.
- La relación exacta entre cada registro de asistencia y la inscripción del alumno.
- El mecanismo técnico que activará automáticamente las asignaciones programadas.
- Los detalles técnicos de las actividades de recuperación, incluidos los casos en que no exista un criterio equivalente en el grupo destino.
- La forma de registrar y consultar justificaciones, si se requiere información adicional a marcar el estado JUSTIFICADO.
- La distribución final de vistas, controladores, servicios y DAO según el código compartido.

Estos puntos no deben resolverse mediante cambios unilaterales en la base de datos. Se deberán presentar al responsable correspondiente para su revisión.

---

**Nota de implementación:** Este documento describe el alcance funcional aprobado y distingue las entidades existentes de las propuestas pendientes. Antes de programar consultas SQL o crear tablas, se deberá contrastar cada operación con el diccionario de datos vigente y con la estructura física real de la base de datos.


## 16. Sustitución docente y continuidad del trabajo académico

Cuando un profesor sea sustituido en un grupo:

- El Director finaliza la asignación anterior y registra una nueva asignación para el profesor sustituto.
- El profesor sustituto consulta los grupos y materias que le fueron asignados conforme a la vigencia de su nueva asignación.
- Las actividades, calificaciones y asistencias ya registradas no cambian de autor ni de asignación. Se conserva su vínculo histórico.
- El sustituto puede consultar la información académica necesaria para dar continuidad al trabajo del grupo.
- El sustituto puede crear nuevas actividades y registrar nuevas calificaciones y asistencias durante la vigencia de su propia asignación, respetando los plazos y reglas del sistema.
- La sustitución no crea una nueva versión de la configuración de evaluación. El sustituto continúa utilizando la configuración vigente para la materia, grupo y periodo.
- Las actividades nuevas deben quedar identificadas con el profesor y la asignación que las generaron.
- Las correcciones de registros históricos se tramitan mediante el procedimiento de autorización correspondiente; no se deben alterar directamente para cambiar su autoría.

El módulo Profesor y Asistencia no realiza la sustitución administrativa ni modifica las asignaciones docentes: esas acciones corresponden al módulo Director.

## 17. Cambios de grupo y reincorporaciones: continuidad de asistencia

Cuando un alumno cambia de grupo durante un periodo o se reincorpora después de una baja temporal:

- La inscripción anterior permanece finalizada y se crea una nueva inscripción.
- Las asistencias registradas anteriormente permanecen asociadas a la inscripción original.
- No se trasladan asistencias al grupo destino ni se combinan registros de distintas inscripciones.
- La captura de asistencia para la nueva inscripción comienza a partir de la fecha de incorporación o reincorporación.
- El profesor debe consultar la inscripción vigente que corresponda a la fecha de la sesión antes de registrar asistencia.
- No se deben crear registros retroactivos para sesiones anteriores a la fecha en que el alumno quedó inscrito en el grupo.

Estas reglas mantienen la trazabilidad de la asistencia y evitan atribuir al alumno registros de un grupo en el que todavía no estaba inscrito.
