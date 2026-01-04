-- =============================================================================
-- OrangeHRM Test Automation - Database Schema
-- Author: Saja Ayyad
-- Date: 2025-01-03
-- Description: Complete database schema for test data management
-- =============================================================================

CREATE DATABASE IF NOT EXISTS orangehrm_test_db;
USE orangehrm_test_db;

-- =============================================================================
-- Table 1: Test Suites
-- =============================================================================
CREATE TABLE IF NOT EXISTS test_suites (
    suite_id INT PRIMARY KEY AUTO_INCREMENT,
    suite_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_suite_name (suite_name),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- Table 2: Test Cases
-- =============================================================================
CREATE TABLE IF NOT EXISTS test_cases (
    test_case_id INT PRIMARY KEY AUTO_INCREMENT,
    suite_id INT NOT NULL,
    test_case_name VARCHAR(100) NOT NULL,
    description TEXT,
    priority VARCHAR(20) DEFAULT 'MEDIUM',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (suite_id) REFERENCES test_suites(suite_id) ON DELETE CASCADE,
    UNIQUE KEY unique_test_case (suite_id, test_case_name),
    INDEX idx_test_case_name (test_case_name),
    INDEX idx_priority (priority)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- Table 3: Test Input Data (Replaces input.json files)
-- =============================================================================
CREATE TABLE IF NOT EXISTS test_input_data (
    input_id INT PRIMARY KEY AUTO_INCREMENT,
    test_case_id INT NOT NULL,
    config_data JSON NOT NULL COMMENT 'Complete test configuration as JSON',
    base_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    version INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (test_case_id) REFERENCES test_cases(test_case_id) ON DELETE CASCADE,
    INDEX idx_test_case_id (test_case_id),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- Table 4: Test Baselines (Replaces Expected/baseline.txt files)
-- =============================================================================
CREATE TABLE IF NOT EXISTS test_baselines (
    baseline_id INT PRIMARY KEY AUTO_INCREMENT,
    test_case_id INT NOT NULL,
    baseline_type VARCHAR(50) DEFAULT 'url' COMMENT 'url, validation_message, alert_message, etc.',
    expected_value TEXT NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    version INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (test_case_id) REFERENCES test_cases(test_case_id) ON DELETE CASCADE,
    INDEX idx_test_case_id (test_case_id),
    INDEX idx_baseline_type (baseline_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- Table 5: Test Executions
-- =============================================================================
CREATE TABLE IF NOT EXISTS test_executions (
    execution_id INT PRIMARY KEY AUTO_INCREMENT,
    execution_name VARCHAR(200),
    browser VARCHAR(50),
    environment VARCHAR(50) DEFAULT 'staging',
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    total_tests INT DEFAULT 0,
    passed_tests INT DEFAULT 0,
    failed_tests INT DEFAULT 0,
    skipped_tests INT DEFAULT 0,
    status VARCHAR(50) DEFAULT 'RUNNING' COMMENT 'RUNNING, COMPLETED, FAILED, ABORTED',
    triggered_by VARCHAR(100),
    
    INDEX idx_status (status),
    INDEX idx_started_at (started_at),
    INDEX idx_environment (environment)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- Table 6: Test Results (Replaces Actual/baseline.txt files)
-- =============================================================================
CREATE TABLE IF NOT EXISTS test_results (
    result_id INT PRIMARY KEY AUTO_INCREMENT,
    execution_id INT NOT NULL,
    test_case_id INT NOT NULL,
    baseline_id INT,
    actual_value TEXT,
    expected_value TEXT,
    comparison_result VARCHAR(20) COMMENT 'PASS, FAIL, ERROR, SKIP',
    error_message TEXT,
    stack_trace TEXT,
    duration_ms BIGINT,
    screenshot_path VARCHAR(500),
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    
    FOREIGN KEY (execution_id) REFERENCES test_executions(execution_id) ON DELETE CASCADE,
    FOREIGN KEY (test_case_id) REFERENCES test_cases(test_case_id) ON DELETE CASCADE,
    FOREIGN KEY (baseline_id) REFERENCES test_baselines(baseline_id) ON DELETE SET NULL,
    INDEX idx_execution_id (execution_id),
    INDEX idx_test_case_id (test_case_id),
    INDEX idx_comparison_result (comparison_result),
    INDEX idx_started_at (started_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- Table 7: Baseline Comparisons (Replaces Diff/baseline_diff.txt files)
-- =============================================================================
CREATE TABLE IF NOT EXISTS baseline_comparisons (
    comparison_id INT PRIMARY KEY AUTO_INCREMENT,
    result_id INT NOT NULL,
    baseline_id INT NOT NULL,
    expected_value TEXT,
    actual_value TEXT,
    diff_details TEXT,
    match_status VARCHAR(20) COMMENT 'MATCH, MISMATCH, PARTIAL_MATCH',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (result_id) REFERENCES test_results(result_id) ON DELETE CASCADE,
    FOREIGN KEY (baseline_id) REFERENCES test_baselines(baseline_id) ON DELETE CASCADE,
    INDEX idx_result_id (result_id),
    INDEX idx_match_status (match_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- Table 8: Test Steps (Optional - for detailed step-by-step logging)
-- =============================================================================
CREATE TABLE IF NOT EXISTS test_steps (
    step_id INT PRIMARY KEY AUTO_INCREMENT,
    result_id INT NOT NULL,
    step_number INT NOT NULL,
    step_description TEXT,
    status VARCHAR(20) COMMENT 'PASS, FAIL, SKIP',
    step_data TEXT,
    screenshot_path VARCHAR(500),
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (result_id) REFERENCES test_results(result_id) ON DELETE CASCADE,
    INDEX idx_result_id (result_id),
    INDEX idx_step_number (step_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- Verification Queries
-- =============================================================================

-- Show all tables
SHOW TABLES;

-- Confirmation message
SELECT 
    '✓ Database schema created successfully!' as status,
    COUNT(*) as total_tables
FROM information_schema.tables 
WHERE table_schema = 'orangehrm_test_db';