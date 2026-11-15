package com.ric.ric.profesor.model;

public class Grupo {
    private int id;
    private String nombre;

    public Grupo() {
    }

    public Grupo(int id, String nombre) {
        this.id = id;
        this.nombre = nombre;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    // Esto hace que el ComboBox muestre "1° A" directamente en lugar de la dirección de memoria
    @Override
    public String toString() {
        return nombre;
    }
}