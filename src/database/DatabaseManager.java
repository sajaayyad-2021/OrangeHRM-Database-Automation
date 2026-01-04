package database;

import java.sql.*;
import java.util.Properties;

public class DatabaseManager {
    
    private static DatabaseManager instance;
    private Connection connection;
    
    // Database configuration
    private static final String DB_URL = "jdbc:mysql://localhost:3306/orangehrm_test_db";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "root1234";
    
    private DatabaseManager() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            Properties props = new Properties();
            props.setProperty("user", DB_USER);
            props.setProperty("password", DB_PASSWORD);
            props.setProperty("useSSL", "false");
            props.setProperty("allowPublicKeyRetrieval", "true");
            
            connection = DriverManager.getConnection(DB_URL, props);
            
            System.out.println("✓ Database connected successfully!");
            
        } catch (ClassNotFoundException e) {
            System.err.println("MySQL Driver not found!");
            e.printStackTrace();
        } catch (SQLException e) {
            System.err.println("Database connection failed!");
            e.printStackTrace();
        }
    }
    
    public static synchronized DatabaseManager getInstance() {
        if (instance == null) {
            instance = new DatabaseManager();
        }
        return instance;
    }
    
    public Connection getConnection() {
        try {
            if (connection == null || connection.isClosed()) {
                instance = new DatabaseManager();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return connection;
    }
    
    public boolean testConnection() {
        try {
            return connection != null && !connection.isClosed();
        } catch (SQLException e) {
            return false;
        }
    }
    
    public void closeConnection() {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
                System.out.println("✓ Database connection closed");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
