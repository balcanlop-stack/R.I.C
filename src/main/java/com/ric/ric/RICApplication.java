package com.ric.ric;

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.stage.Stage;

import java.io.IOException;

public class RICApplication extends Application {

    @Override
    public void start(Stage stage) throws IOException {

        FXMLLoader loader = new FXMLLoader(
                RICApplication.class.getResource("/fxml/login-view.fxml")
        );

        Scene scene = new Scene(loader.load());

        stage.setTitle("R.I.C. - Registro Integral de Calificaciones");
        stage.setScene(scene);
        stage.setResizable(false);
        stage.show();
    }
}