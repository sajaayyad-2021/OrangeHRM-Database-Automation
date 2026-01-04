-- =============================================================================
-- Seed Test Cases (19 total)
-- =============================================================================

USE orangehrm_test_db;
USE orangehrm_test_db;
DESCRIBE test_cases;

-- Check if test cases already exist
SELECT * FROM test_cases;

-- If you see data, delete it first
DELETE FROM test_cases;

-- Reset auto increment
ALTER TABLE test_cases AUTO_INCREMENT = 1;

-- Now run 02_test_cases.sql
-- Add priority column to test_cases table

-- ADD COLUMN priority VARCHAR(20) DEFAULT 'MEDIUM' AFTER description;

-- Verify
USE orangehrm_test_db;

-- Check existing test cases
SELECT 
    ts.suite_name,
    tc.test_case_name,
    tc.priority
FROM test_cases tc
JOIN test_suites ts ON tc.suite_id = ts.suite_id
ORDER BY ts.suite_id, tc.test_case_id;
-- =============================================================================
-- LOGIN TEST CASES (5 cases)
-- =============================================================================

INSERT INTO test_cases (suite_id, test_case_name, description, priority) 
SELECT suite_id, 'TC_LOG_001_validLogin', 'Valid login with correct credentials', 'CRITICAL'
FROM test_suites WHERE suite_name = 'LoginTests';

INSERT INTO test_cases (suite_id, test_case_name, description, priority) 
SELECT suite_id, 'TC_LOG_003_emptyFields', 'Empty username and password validation', 'HIGH'
FROM test_suites WHERE suite_name = 'LoginTests';

INSERT INTO test_cases (suite_id, test_case_name, description, priority) 
SELECT suite_id, 'TC_LOG_004_emptyPasswordOnly', 'Empty password field validation', 'HIGH'
FROM test_suites WHERE suite_name = 'LoginTests';

INSERT INTO test_cases (suite_id, test_case_name, description, priority) 
SELECT suite_id, 'TC_LOG_008_invalidBoth', 'Invalid username and password', 'CRITICAL'
FROM test_suites WHERE suite_name = 'LoginTests';

INSERT INTO test_cases (suite_id, test_case_name, description, priority) 
SELECT suite_id, 'TC_LOG_009_logoutRedirect', 'Logout and redirect to login page', 'MEDIUM'
FROM test_suites WHERE suite_name = 'LoginTests';

-- =============================================================================
-- PIM TEST CASES (8 cases)
-- =============================================================================

INSERT INTO test_cases (suite_id, test_case_name, description, priority) VALUES
((SELECT suite_id FROM test_suites WHERE suite_name = 'PIMTests'), 'TC_PIM_001_addEmployeeValid', 'Add employee with all fields (first, middle, last name)', 'CRITICAL'),
((SELECT suite_id FROM test_suites WHERE suite_name = 'PIMTests'), 'TC_PIM_002_addEmployeeNoMiddleName', 'Add employee without middle name', 'HIGH'),
((SELECT suite_id FROM test_suites WHERE suite_name = 'PIMTests'), 'TC_PIM_003_addEmployeeMissingFirstName', 'Validation test - missing first name', 'HIGH'),
((SELECT suite_id FROM test_suites WHERE suite_name = 'PIMTests'), 'TC_PIM_004_addEmployeeMissingLastName', 'Validation test - missing last name', 'HIGH'),
((SELECT suite_id FROM test_suites WHERE suite_name = 'PIMTests'), 'TC_PIM_005_addEmployeeMissingBoth', 'Validation test - missing both first and last names', 'HIGH'),
((SELECT suite_id FROM test_suites WHERE suite_name = 'PIMTests'), 'TC_PIM_006_searchByValidName', 'Search employee by valid name', 'MEDIUM'),
((SELECT suite_id FROM test_suites WHERE suite_name = 'PIMTests'), 'TC_PIM_007_searchByInvalidName', 'Search employee by invalid/non-existent name', 'MEDIUM'),
((SELECT suite_id FROM test_suites WHERE suite_name = 'PIMTests'), 'TC_PIM_008_searchByInvalidId', 'Search employee by invalid/non-existent ID', 'MEDIUM');

-- =============================================================================
-- LEAVE TEST CASES (6 cases)
-- =============================================================================

INSERT INTO test_cases (suite_id, test_case_name, description, priority) VALUES
((SELECT suite_id FROM test_suites WHERE suite_name = 'LeaveTests'), 'TC_LEAVE_001_basicSearch', 'Basic leave search with date range', 'HIGH'),
((SELECT suite_id FROM test_suites WHERE suite_name = 'LeaveTests'), 'TC_LEAVE_002_searchWithEmployeeName', 'Leave search filtered by employee name', 'MEDIUM'),
((SELECT suite_id FROM test_suites WHERE suite_name = 'LeaveTests'), 'TC_LEAVE_003_invalidDateToDate', 'Invalid date range (To date before From date)', 'MEDIUM'),
((SELECT suite_id FROM test_suites WHERE suite_name = 'LeaveTests'), 'TC_LEAVE_004_selectLeaveStatus', 'Filter leave records by status', 'MEDIUM'),
((SELECT suite_id FROM test_suites WHERE suite_name = 'LeaveTests'), 'TC_LEAVE_005_selectLeaveType', 'Filter leave records by leave type', 'MEDIUM'),
((SELECT suite_id FROM test_suites WHERE suite_name = 'LeaveTests'), 'TC_LEAVE_006_resetButton', 'Test reset filters functionality', 'LOW');

-- =============================================================================
-- Verification
-- =============================================================================

SELECT 
    '✓ Test cases seeded successfully!' as status,
    COUNT(*) as total_test_cases
FROM test_cases;

-- Summary by suite
SELECT 
    ts.suite_name,
    COUNT(tc.test_case_id) as test_count
FROM test_suites ts
LEFT JOIN test_cases tc ON ts.suite_id = tc.suite_id
GROUP BY ts.suite_name
ORDER BY ts.suite_id;

-- Show all test cases
SELECT 
    ts.suite_name,
    tc.test_case_name,
    tc.description,
    tc.priority
FROM test_cases tc
JOIN test_suites ts ON tc.suite_id = ts.suite_id
ORDER BY ts.suite_id, tc.test_case_id;

USE orangehrm_test_db;

SELECT 
    'Test Cases (Total)' as item,
    COUNT(*) as count
FROM test_cases

UNION ALL

SELECT 
    'Login Tests',
    COUNT(*)
FROM test_cases
WHERE test_case_name LIKE 'TC_LOG%'

UNION ALL

SELECT 
    'PIM Tests',
    COUNT(*)
FROM test_cases
WHERE test_case_name LIKE 'TC_PIM%'

UNION ALL

SELECT 
    'Leave Tests',
    COUNT(*)
FROM test_cases
WHERE test_case_name LIKE 'TC_LEAVE%';


