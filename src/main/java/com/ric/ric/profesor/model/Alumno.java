package com.ric.ric.profesor.model;

public class Alumno {
    private String matricula;
    private String nombre;
    private int idGrupo; // Clave foránea para relacionarlo con Grupo en MySQL

    public Alumno() {
    }

    public Alumno(String matricula, String nombre) {
        this.matricula = matricula;
        this.nombre = nombre;
    }

    public Alumno(String matricula, String nombre, int idGrupo) {
        this.matricula = matricula;
        this.nombre = nombre;
        this.idGrupo = idGrupo;
    }

    public String getMatricula() {
        return matricula;
    }

    public void setMatricula(String matricula) {
        this.matricula = matricula;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public int getIdGrupo() {
        return idGrupo;
    }

    public void setIdGrupo(int idGrupo) {
        this.idGrupo = idGrupo;
    }
}