
package com.ric.ric;

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.stage.Stage;

import java.io.IOException;

public class HelloApplication extends Application {

    @Override
    public void start(Stage stage) throws IOException {

        FXMLLoader fxmlLoader = new FXMLLoader(
                HelloApplication.class.getResource(
                        "/com/ric/ric/profesor/profesor-view.fxml"
                )
        );

        Scene scene = new Scene(fxmlLoader.load(), 1150, 760);

        scene.getStylesheets().add(
                HelloApplication.class.getResource(
                        "/com/ric/ric/profesor/estilos-profesor.css"
                ).toExternalForm()
        );

        stage.setTitle("R.I.C. - Panel del Profesor");
        stage.setMinWidth(950);
        stage.setMinHeight(650);
        stage.setScene(scene);
        stage.show();
    }
}
