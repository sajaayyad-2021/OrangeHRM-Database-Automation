package database;

import java.sql.*;

public class TestResultDAO {
    
    private Connection conn;
    
    public TestResultDAO() {
        this.conn = DatabaseManager.getInstance().getConnection();
    }
    
    /**
     * Create new test execution
     */
    public int createExecution(String browser, String environment) {
        
        try {
            String sql = "INSERT INTO test_executions (execution_name, browser, base_url, status) " +
                         "VALUES (?, ?, ?, 'RUNNING')";
            
            try (PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                pstmt.setString(1, "Test Run - " + new java.util.Date());
                pstmt.setString(2, browser);
                pstmt.setString(3, "");
                
                pstmt.executeUpdate();
                
                ResultSet rs = pstmt.getGeneratedKeys();
                if (rs.next()) {
                    int executionId = rs.getInt(1);
                    System.out.println("SUCCESS: Test execution created: ID = " + executionId);
                    return executionId;
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return -1;
    }
    
    /**
     * Get baseline ID for test
     */
    public int getBaselineIdForTest(int testCaseId, String baselineType) {
        
        try {
            String sql = "SELECT baseline_id FROM baselines " +
                         "WHERE test_case_id = ? AND baseline_type = ? AND is_active = TRUE " +
                         "ORDER BY version DESC LIMIT 1";
            
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, testCaseId);
                pstmt.setString(2, baselineType);
                
                ResultSet rs = pstmt.executeQuery();
                if (rs.next()) {
                    return rs.getInt("baseline_id");
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return -1;
    }
    
    /**
     * Save test result
     */
    public int saveTestResult(int executionId, int testCaseId, int baselineId, 
                              String actualValue, String expectedValue, 
                              String comparisonResult, String errorMessage, 
                              long durationMs, String screenshotPath) {
        
        try {
            String sql = "INSERT INTO test_results " +
                         "(execution_id, test_case_id, baseline_id, actual_value, expected_value, " +
                         "comparison_result, error_message, duration_ms, screenshot_path, completed_at) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)";
            
            try (PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                pstmt.setInt(1, executionId);
                pstmt.setInt(2, testCaseId);
                
                if (baselineId > 0) {
                    pstmt.setInt(3, baselineId);
                } else {
                    pstmt.setNull(3, Types.INTEGER);
                }
                
                pstmt.setString(4, actualValue);
                pstmt.setString(5, expectedValue);
                pstmt.setString(6, comparisonResult);
                pstmt.setString(7, errorMessage);
                pstmt.setLong(8, durationMs);
                pstmt.setString(9, screenshotPath);
                
                pstmt.executeUpdate();
                
                ResultSet rs = pstmt.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return -1;
    }
    
    /**
     * Save baseline comparison
     */
    public void saveBaselineComparison(int resultId, int baselineId, 
                                       String expectedValue, String actualValue, 
                                       String diffDetails, String matchStatus) {
        
        try {
            String sql = "INSERT INTO baseline_comparisons " +
                         "(result_id, baseline_id, expected_value, actual_value, diff_details, match_status) " +
                         "VALUES (?, ?, ?, ?, ?, ?)";
            
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, resultId);
                pstmt.setInt(2, baselineId);
                pstmt.setString(3, expectedValue);
                pstmt.setString(4, actualValue);
                pstmt.setString(5, diffDetails);
                pstmt.setString(6, matchStatus);
                
                pstmt.executeUpdate();
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    /**
     * Finalize execution
     */
    public void finalizeExecution(int executionId, int passed, int failed, int total) {
        
        try {
            String sql = "UPDATE test_executions SET " +
                         "completed_at = CURRENT_TIMESTAMP, " +
                         "total_tests = ?, " +
                         "passed_tests = ?, " +
                         "failed_tests = ?, " +
                         "status = 'COMPLETED' " +
                         "WHERE execution_id = ?";
            
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, total);
                pstmt.setInt(2, passed);
                pstmt.setInt(3, failed);
                pstmt.setInt(4, executionId);
                
                pstmt.executeUpdate();
                
                System.out.println("SUCCESS: Execution finalized: " + passed + "/" + total + " passed");
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}