package com.ric.ric.profesor.controller;

import com.ric.ric.profesor.model.Alumno;
import com.ric.ric.profesor.model.Grupo;
import com.ric.ric.profesor.service.GrupoService;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.fxml.FXML;
import javafx.scene.control.ComboBox;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.scene.control.cell.PropertyValueFactory;

public class GruposController {

    @FXML
    private ComboBox<Grupo> cmbGrupos;

    @FXML
    private TableView<Alumno> tblAlumnos;

    @FXML
    private TableColumn<Alumno, String> colMatricula;

    @FXML
    private TableColumn<Alumno, String> colNombre;

    private final GrupoService grupoService = new GrupoService();

    @FXML
    public void initialize() {
        // 1. Enlazar las columnas de la tabla con los atributos de Alumno.java
        colMatricula.setCellValueFactory(new PropertyValueFactory<>("matricula"));
        colNombre.setCellValueFactory(new PropertyValueFactory<>("nombre"));

        // 2. Cargar los grupos en el ComboBox desde GrupoService
        ObservableList<Grupo> listaGrupos = FXCollections.observableArrayList(grupoService.obtenerGrupos());
        cmbGrupos.setItems(listaGrupos);

        // 3. Detectar cuando el profesor selecciona un grupo para cargar sus alumnos
        cmbGrupos.getSelectionModel().selectedItemProperty().addListener((obs, grupoAnterior, grupoSeleccionado) -> {
            if (grupoSeleccionado != null) {
                cargarAlumnos(grupoSeleccionado.getId());
            }
        });

        // 4. Seleccionar el primer grupo ("1° A") por defecto al abrir la vista
        if (!listaGrupos.isEmpty()) {
            cmbGrupos.getSelectionModel().selectFirst();
        }
    }

    private void cargarAlumnos(int idGrupo) {
        ObservableList<Alumno> alumnos = FXCollections.observableArrayList(
                grupoService.obtenerAlumnosPorGrupo(idGrupo)
        );
        tblAlumnos.setItems(alumnos);
    }
}