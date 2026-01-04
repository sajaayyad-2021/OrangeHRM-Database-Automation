-- =============================================================================
-- Seed Leave Test Data (6 test cases)
-- =============================================================================

USE orangehrm_test_db;

-- =============================================================================
-- TC_LEAVE_001: Basic Search
-- =============================================================================
INSERT INTO test_input_data (test_case_id, config_data, base_url, version)
SELECT 
    test_case_id,
    JSON_OBJECT(
        'baseURL', 'https://opensource-demo.orangehrmlive.com',
        'auth', JSON_OBJECT(
            'userName', 'Admin',
            'passWord', 'admin123'
        ),
        'leaveSearch', JSON_OBJECT(
            'fromDate', '2024-01-01',
            'toDate', '2024-12-31',
            'employeeName', '',
            'status', '',
            'leaveType', '',
            'subUnit', '',
            'resetFilters', false
        )
    ),
    'https://opensource-demo.orangehrmlive.com',
    1
FROM test_cases 
WHERE test_case_name = 'TC_LEAVE_001_basicSearch';

INSERT INTO test_baselines (test_case_id, baseline_type, expected_value, description, version)
SELECT 
    test_case_id,
    'url',
    'https://opensource-demo.orangehrmlive.com/web/index.php/leave/viewLeaveList',
    'Expected leave list page',
    1
FROM test_cases 
WHERE test_case_name = 'TC_LEAVE_001_basicSearch';

-- =============================================================================
-- TC_LEAVE_002: Search With Employee Name
-- =============================================================================
INSERT INTO test_input_data (test_case_id, config_data, base_url, version)
SELECT 
    test_case_id,
    JSON_OBJECT(
        'baseURL', 'https://opensource-demo.orangehrmlive.com',
        'auth', JSON_OBJECT(
            'userName', 'Admin',
            'passWord', 'admin123'
        ),
        'leaveSearch', JSON_OBJECT(
            'fromDate', '2024-01-01',
            'toDate', '2024-12-31',
            'employeeName', 'Linda Anderson',
            'status', '',
            'leaveType', '',
            'subUnit', '',
            'resetFilters', false
        )
    ),
    'https://opensource-demo.orangehrmlive.com',
    1
FROM test_cases 
WHERE test_case_name = 'TC_LEAVE_002_searchWithEmployeeName';

INSERT INTO test_baselines (test_case_id, baseline_type, expected_value, description, version)
SELECT 
    test_case_id,
    'url',
    'https://opensource-demo.orangehrmlive.com/web/index.php/leave/viewLeaveList',
    'Expected filtered leave list by employee name',
    1
FROM test_cases 
WHERE test_case_name = 'TC_LEAVE_002_searchWithEmployeeName';

-- =============================================================================
-- TC_LEAVE_003: Invalid Date Range
-- =============================================================================
INSERT INTO test_input_data (test_case_id, config_data, base_url, version)
SELECT 
    test_case_id,
    JSON_OBJECT(
        'baseURL', 'https://opensource-demo.orangehrmlive.com',
        'auth', JSON_OBJECT(
            'userName', 'Admin',
            'passWord', 'admin123'
        ),
        'leaveSearch', JSON_OBJECT(
            'fromDate', '2024-12-31',
            'toDate', '2024-01-01',
            'employeeName', '',
            'status', '',
            'leaveType', '',
            'subUnit', '',
            'resetFilters', false
        )
    ),
    'https://opensource-demo.orangehrmlive.com',
    1
FROM test_cases 
WHERE test_case_name = 'TC_LEAVE_003_invalidDateToDate';

INSERT INTO test_baselines (test_case_id, baseline_type, expected_value, description, version)
SELECT 
    test_case_id,
    'url',
    'https://opensource-demo.orangehrmlive.com/web/index.php/leave/viewLeaveList',
    'Expected leave list (may show error or no records)',
    1
FROM test_cases 
WHERE test_case_name = 'TC_LEAVE_003_invalidDateToDate';

-- =============================================================================
-- TC_LEAVE_004: Select Leave Status
-- =============================================================================
INSERT INTO test_input_data (test_case_id, config_data, base_url, version)
SELECT 
    test_case_id,
    JSON_OBJECT(
        'baseURL', 'https://opensource-demo.orangehrmlive.com',
        'auth', JSON_OBJECT(
            'userName', 'Admin',
            'passWord', 'admin123'
        ),
        'leaveSearch', JSON_OBJECT(
            'fromDate', '2024-01-01',
            'toDate', '2024-12-31',
            'employeeName', '',
            'status', 'Scheduled',
            'leaveType', '',
            'subUnit', '',
            'resetFilters', false
        )
    ),
    'https://opensource-demo.orangehrmlive.com',
    1
FROM test_cases 
WHERE test_case_name = 'TC_LEAVE_004_selectLeaveStatus';

INSERT INTO test_baselines (test_case_id, baseline_type, expected_value, description, version)
SELECT 
    test_case_id,
    'url',
    'https://opensource-demo.orangehrmlive.com/web/index.php/leave/viewLeaveList',
    'Expected leave list filtered by status',
    1
FROM test_cases 
WHERE test_case_name = 'TC_LEAVE_004_selectLeaveStatus';

-- =============================================================================
-- TC_LEAVE_005: Select Leave Type
-- =============================================================================
INSERT INTO test_input_data (test_case_id, config_data, base_url, version)
SELECT 
    test_case_id,
    JSON_OBJECT(
        'baseURL', 'https://opensource-demo.orangehrmlive.com',
        'auth', JSON_OBJECT(
            'userName', 'Admin',
            'passWord', 'admin123'
        ),
        'leaveSearch', JSON_OBJECT(
            'fromDate', '2024-01-01',
            'toDate', '2024-12-31',
            'employeeName', '',
            'status', '',
            'leaveType', 'CAN - Vacation',
            'subUnit', '',
            'resetFilters', false
        )
    ),
    'https://opensource-demo.orangehrmlive.com',
    1
FROM test_cases 
WHERE test_case_name = 'TC_LEAVE_005_selectLeaveType';

INSERT INTO test_baselines (test_case_id, baseline_type, expected_value, description, version)
SELECT 
    test_case_id,
    'url',
    'https://opensource-demo.orangehrmlive.com/web/index.php/leave/viewLeaveList',
    'Expected leave list filtered by type',
    1
FROM test_cases 
WHERE test_case_name = 'TC_LEAVE_005_selectLeaveType';

-- =============================================================================
-- TC_LEAVE_006: Reset Button
-- =============================================================================
INSERT INTO test_input_data (test_case_id, config_data, base_url, version)
SELECT 
    test_case_id,
    JSON_OBJECT(
        'baseURL', 'https://opensource-demo.orangehrmlive.com',
        'auth', JSON_OBJECT(
            'userName', 'Admin',
            'passWord', 'admin123'
        ),
        'leaveSearch', JSON_OBJECT(
            'fromDate', '2024-01-01',
            'toDate', '2024-12-31',
            'employeeName', 'John Doe',
            'status', 'Scheduled',
            'leaveType', 'CAN - Vacation',
            'subUnit', 'Engineering',
            'resetFilters', true
        )
    ),
    'https://opensource-demo.orangehrmlive.com',
    1
FROM test_cases 
WHERE test_case_name = 'TC_LEAVE_006_resetButton';

INSERT INTO test_baselines (test_case_id, baseline_type, expected_value, description, version)
SELECT 
    test_case_id,
    'url',
    'https://opensource-demo.orangehrmlive.com/web/index.php/leave/viewLeaveList',
    'Expected leave list after reset',
    1
FROM test_cases 
WHERE test_case_name = 'TC_LEAVE_006_resetButton';

-- =============================================================================
-- Verification
-- =============================================================================

SELECT 
    '✓ Leave test data seeded successfully!' as status,
    (SELECT COUNT(*) FROM test_input_data WHERE test_case_id IN (SELECT test_case_id FROM test_cases WHERE test_case_name LIKE 'TC_LEAVE%')) as input_data_count,
    (SELECT COUNT(*) FROM test_baselines WHERE test_case_id IN (SELECT test_case_id FROM test_cases WHERE test_case_name LIKE 'TC_LEAVE%')) as baseline_count;

-- Show Leave test data summary
SELECT 
    tc.test_case_name,
    JSON_EXTRACT(ti.config_data, '$.leaveSearch.fromDate') as fromDate,
    JSON_EXTRACT(ti.config_data, '$.leaveSearch.toDate') as toDate,
    JSON_EXTRACT(ti.config_data, '$.leaveSearch.employeeName') as employeeName,
    JSON_EXTRACT(ti.config_data, '$.leaveSearch.status') as status,
    tb.baseline_type,
    LEFT(tb.expected_value, 50) as expected_value_preview
FROM test_cases tc
LEFT JOIN test_input_data ti ON tc.test_case_id = ti.test_case_id
LEFT JOIN test_baselines tb ON tc.test_case_id = tb.test_case_id
WHERE tc.test_case_name LIKE 'TC_LEAVE%'
ORDER BY tc.test_case_id;