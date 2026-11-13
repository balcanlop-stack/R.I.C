package com.ric.ric.controller;

import javafx.fxml.FXML;
import javafx.scene.control.Label;

public class LoginController {

    @FXML
    private Label welcomeText;

    @FXML
    protected void onHelloButtonClick() {

        welcomeText.setText("Bienvenido al sistema R.I.C.");

    }
}