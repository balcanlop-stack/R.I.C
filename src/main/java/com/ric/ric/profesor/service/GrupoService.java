package com.ric.ric.profesor.service;

import com.ric.ric.profesor.model.Alumno;
import com.ric.ric.profesor.model.Grupo;
import java.util.ArrayList;
import java.util.List;

public class GrupoService {

    // Devuelve la lista de grupos asignados al profesor (datos de prueba antes de MySQL)
    public List<Grupo> obtenerGrupos() {
        List<Grupo> grupos = new ArrayList<>();
        grupos.add(new Grupo(1, "1° A"));
        grupos.add(new Grupo(2, "2° B"));
        grupos.add(new Grupo(3, "3° C"));
        return grupos;
    }

    // Devuelve los alumnos correspondientes al grupo seleccionado
    public List<Alumno> obtenerAlumnosPorGrupo(int idGrupo) {
        List<Alumno> alumnos = new ArrayList<>();

        if (idGrupo == 1) {
            alumnos.add(new Alumno("001", "Alumno de prueba 1", 1));
            alumnos.add(new Alumno("002", "Alumno de prueba 2", 1));
            alumnos.add(new Alumno("003", "Alumno de prueba 3", 1));
        } else if (idGrupo == 2) {
            alumnos.add(new Alumno("004", "Alumno de prueba 4", 2));
            alumnos.add(new Alumno("005", "Alumno de prueba 5", 2));
        } else if (idGrupo == 3) {
            alumnos.add(new Alumno("006", "Alumno de prueba 6", 3));
        }

        return alumnos;
    }
}