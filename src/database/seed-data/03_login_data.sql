-- =============================================================================
-- Seed Login Test Data (5 test cases)
-- =============================================================================

USE orangehrm_test_db;

-- =============================================================================
-- TC_LOG_001: Valid Login
-- =============================================================================
INSERT INTO test_input_data (test_case_id, config_data, base_url, version)
SELECT 
    test_case_id,
    JSON_OBJECT(
        'baseURL', 'https://opensource-demo.orangehrmlive.com',
        'auth', JSON_OBJECT(
            'userName', 'Admin',
            'passWord', 'admin123'
        )
    ),
    'https://opensource-demo.orangehrmlive.com',
    1
FROM test_cases 
WHERE test_case_name = 'TC_LOG_001_validLogin';

INSERT INTO test_baselines (test_case_id, baseline_type, expected_value, description, version)
SELECT 
    test_case_id,
    'url',
    'https://opensource-demo.orangehrmlive.com/web/index.php/dashboard/index',
    'Expected dashboard URL after successful login',
    1
FROM test_cases 
WHERE test_case_name = 'TC_LOG_001_validLogin';

-- =============================================================================
-- TC_LOG_003: Empty Fields
-- =============================================================================
INSERT INTO test_input_data (test_case_id, config_data, base_url, version)
SELECT 
    test_case_id,
    JSON_OBJECT(
        'baseURL', 'https://opensource-demo.orangehrmlive.com',
        'auth', JSON_OBJECT(
            'userName', '',
            'passWord', ''
        )
    ),
    'https://opensource-demo.orangehrmlive.com',
    1
FROM test_cases 
WHERE test_case_name = 'TC_LOG_003_emptyFields';

INSERT INTO test_baselines (test_case_id, baseline_type, expected_value, description, version)
SELECT 
    test_case_id,
    'validation_message',
    'Required',
    'Expected validation message for empty username and password fields',
    1
FROM test_cases 
WHERE test_case_name = 'TC_LOG_003_emptyFields';

-- =============================================================================
-- TC_LOG_004: Empty Password Only
-- =============================================================================
INSERT INTO test_input_data (test_case_id, config_data, base_url, version)
SELECT 
    test_case_id,
    JSON_OBJECT(
        'baseURL', 'https://opensource-demo.orangehrmlive.com',
        'auth', JSON_OBJECT(
            'userName', 'Admin',
            'passWord', ''
        )
    ),
    'https://opensource-demo.orangehrmlive.com',
    1
FROM test_cases 
WHERE test_case_name = 'TC_LOG_004_emptyPasswordOnly';

INSERT INTO test_baselines (test_case_id, baseline_type, expected_value, description, version)
SELECT 
    test_case_id,
    'validation_message',
    'Required',
    'Expected validation message for empty password field',
    1
FROM test_cases 
WHERE test_case_name = 'TC_LOG_004_emptyPasswordOnly';

-- =============================================================================
-- TC_LOG_008: Invalid Both (Username & Password)
-- =============================================================================
INSERT INTO test_input_data (test_case_id, config_data, base_url, version)
SELECT 
    test_case_id,
    JSON_OBJECT(
        'baseURL', 'https://opensource-demo.orangehrmlive.com',
        'auth', JSON_OBJECT(
            'userName', 'InvalidUser123',
            'passWord', 'InvalidPass456'
        )
    ),
    'https://opensource-demo.orangehrmlive.com',
    1
FROM test_cases 
WHERE test_case_name = 'TC_LOG_008_invalidBoth';

INSERT INTO test_baselines (test_case_id, baseline_type, expected_value, description, version)
SELECT 
    test_case_id,
    'alert_message',
    'Invalid credentials',
    'Expected error message for invalid username and password',
    1
FROM test_cases 
WHERE test_case_name = 'TC_LOG_008_invalidBoth';

-- =============================================================================
-- TC_LOG_009: Logout Redirect
-- =============================================================================
INSERT INTO test_input_data (test_case_id, config_data, base_url, version)
SELECT 
    test_case_id,
    JSON_OBJECT(
        'baseURL', 'https://opensource-demo.orangehrmlive.com',
        'auth', JSON_OBJECT(
            'userName', 'Admin',
            'passWord', 'admin123'
        )
    ),
    'https://opensource-demo.orangehrmlive.com',
    1
FROM test_cases 
WHERE test_case_name = 'TC_LOG_009_logoutRedirect';

INSERT INTO test_baselines (test_case_id, baseline_type, expected_value, description, version)
SELECT 
    test_case_id,
    'url',
    'https://opensource-demo.orangehrmlive.com/web/index.php/auth/login',
    'Expected login page URL after logout',
    1
FROM test_cases 
WHERE test_case_name = 'TC_LOG_009_logoutRedirect';

-- =============================================================================
-- Verification
-- =============================================================================

SELECT 
    '✓ Login test data seeded successfully!' as status,
    (SELECT COUNT(*) FROM test_input_data WHERE test_case_id IN (SELECT test_case_id FROM test_cases WHERE test_case_name LIKE 'TC_LOG%')) as input_data_count,
    (SELECT COUNT(*) FROM test_baselines WHERE test_case_id IN (SELECT test_case_id FROM test_cases WHERE test_case_name LIKE 'TC_LOG%')) as baseline_count;

-- Show all login test data
SELECT 
    tc.test_case_name,
    ti.config_data,
    tb.baseline_type,
    tb.expected_value
FROM test_cases tc
LEFT JOIN test_input_data ti ON tc.test_case_id = ti.test_case_id
LEFT JOIN test_baselines tb ON tc.test_case_id = tb.test_case_id
WHERE tc.test_case_name LIKE 'TC_LOG%'
ORDER BY tc.test_case_id;