package database;

import java.sql.*;
import com.google.gson.*;
import utilites.Config;

public class TestDataDAO {
    
    private Connection conn;
    private Gson gson;
    
    public TestDataDAO() {
        this.conn = DatabaseManager.getInstance().getConnection();
        this.gson = new Gson();
    }
    
    /**
     * Get test case ID by suite name and test case name
     */
    public int getTestCaseId(String suiteName, String testCaseName) throws SQLException {
        
        String sql = "SELECT tc.test_case_id " +
                     "FROM test_cases tc " +
                     "JOIN test_suites ts ON tc.suite_id = ts.suite_id " +
                     "WHERE ts.suite_name = ? AND tc.test_case_name = ?";
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, suiteName);
            pstmt.setString(2, testCaseName);
            
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("test_case_id");
            }
        }
        
        throw new SQLException("Test case not found: " + testCaseName);
    }
    
    /**
     * Get test configuration (replaces loadthisTestConfig)
     */
    public Config getTestConfiguration(String suiteName, String testCaseName) {
        
        try {
            String sql = "SELECT ti.config_data " +
                         "FROM test_input_data ti " +
                         "JOIN test_cases tc ON ti.test_case_id = tc.test_case_id " +
                         "JOIN test_suites ts ON tc.suite_id = ts.suite_id " +
                         "WHERE ts.suite_name = ? AND tc.test_case_name = ? AND ti.is_active = TRUE";
            
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setString(1, suiteName);
                pstmt.setString(2, testCaseName);
                
                ResultSet rs = pstmt.executeQuery();
                if (rs.next()) {
                    String configJson = rs.getString("config_data");
                    
                    // Parse JSON to Config object
                    Config config = gson.fromJson(configJson, Config.class);
                    
                    System.out.println("✓ Config loaded from database: " + testCaseName);
                    return config;
                }
            }
            
        } catch (SQLException e) {
            System.err.println("Error loading config for: " + testCaseName);
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Get expected baseline value
     */
    public String getExpectedBaseline(String suiteName, String testCaseName, String baselineType) {
        
        try {
            String sql = "SELECT tb.expected_value " +
                         "FROM test_baselines tb " +
                         "JOIN test_cases tc ON tb.test_case_id = tc.test_case_id " +
                         "JOIN test_suites ts ON tc.suite_id = ts.suite_id " +
                         "WHERE ts.suite_name = ? AND tc.test_case_name = ? " +
                         "AND tb.baseline_type = ? AND tb.is_active = TRUE";
            
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setString(1, suiteName);
                pstmt.setString(2, testCaseName);
                pstmt.setString(3, baselineType);
                
                ResultSet rs = pstmt.executeQuery();
                if (rs.next()) {
                    return rs.getString("expected_value");
                }
            }
            
        } catch (SQLException e) {
            System.err.println("Error loading baseline for: " + testCaseName);
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Get expected baseline by test case ID
     */
    public String getExpectedBaseline(int testCaseId, String baselineType) {
        
        try {
            String sql = "SELECT expected_value FROM test_baselines " +
                         "WHERE test_case_id = ? AND baseline_type = ? AND is_active = TRUE";
            
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, testCaseId);
                pstmt.setString(2, baselineType);
                
                ResultSet rs = pstmt.executeQuery();
                if (rs.next()) {
                    return rs.getString("expected_value");
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
}
