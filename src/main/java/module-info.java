module com.ric.ric {
    requires javafx.controls;
    requires javafx.fxml;


    opens com.ric.ric to javafx.fxml;
    exports com.ric.ric;
}