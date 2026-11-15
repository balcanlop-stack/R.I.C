package com.ric.ric.profesor.controller;

import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.control.Alert;
import javafx.scene.control.Label;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.VBox;

import java.io.IOException;

public class ProfesorController {

    @FXML
    private BorderPane rootPane;

    @FXML
    private VBox vistaInicio;

    @FXML
    private Label nombreProfesor;

    @FXML
    private Label fechaActual;

    @FXML
    public void initialize() {
        nombreProfesor.setText("Profesor");
        fechaActual.setText("Panel de gestión académica");
    }

    @FXML
    private void mostrarInicio() {
        rootPane.setCenter(vistaInicio);
    }

    @FXML
    private void mostrarGrupos() {
        cargarVista("/com/ric/ric/profesor/grupos.fxml");
    }

    @FXML
    private void mostrarMaterias() {
        mostrarMensaje("Mis materias", "Aquí consultaremos las materias asignadas.");
    }

    @FXML
    private void mostrarCriterios() {
        mostrarMensaje("Criterios de evaluación", "Aquí configuraremos los criterios de evaluación.");
    }

    @FXML
    private void mostrarActividades() {
        mostrarMensaje("Actividades", "Aquí registraremos las actividades de evaluación.");
    }

    @FXML
    private void mostrarCalificaciones() {
        mostrarMensaje("Calificaciones", "Aquí registraremos y consultaremos calificaciones.");
    }

    @FXML
    private void mostrarSolicitudes() {
        mostrarMensaje("Solicitudes", "Aquí atenderemos las solicitudes de corrección.");
    }

    @FXML
    private void cerrarSesion() {
        mostrarMensaje("Cerrar sesión", "La función de cierre de sesión se integrará posteriormente.");
    }

    private void cargarVista(String rutaFxml) {
        try {
            FXMLLoader loader = new FXMLLoader(getClass().getResource(rutaFxml));
            Parent vista = loader.load();
            rootPane.setCenter(vista);
        } catch (IOException e) {
            e.printStackTrace();
            mostrarMensaje("Error", "No se pudo cargar la vista: " + rutaFxml);
        }
    }

    private void mostrarMensaje(String titulo, String mensaje) {
        Alert alerta = new Alert(Alert.AlertType.INFORMATION);
        alerta.setTitle("R.I.C. - " + titulo);
        alerta.setHeaderText(titulo);
        alerta.setContentText(mensaje);
        alerta.showAndWait();
    }
}