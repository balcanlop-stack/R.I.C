module com.ric.ric {

    requires javafx.controls;
    requires javafx.fxml;

    opens com.ric.ric to javafx.fxml;
    opens com.ric.ric.controller to javafx.fxml;

    exports com.ric.ric;
    exports com.ric.ric.controller;

}