module com.ric.ric {
    requires javafx.controls;
    requires javafx.fxml;
    requires transitive javafx.graphics;

    opens com.ric.ric to javafx.fxml;
    opens com.ric.ric.profesor.controller to javafx.fxml;
    opens com.ric.ric.profesor.model to javafx.base;

    exports com.ric.ric;
    exports com.ric.ric.profesor.model;
    exports com.ric.ric.profesor.service;
}