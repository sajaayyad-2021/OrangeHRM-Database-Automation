-- =============================================================================
-- Seed PIM Test Data (8 test cases)
-- =============================================================================

USE orangehrm_test_db;

-- =============================================================================
-- TC_PIM_001: Add Employee Valid (with all fields)
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
        'defaults', JSON_OBJECT(
            'firstName', 'Sama',
            'middleName', 'Yaser',
            'lastName', 'Mohammad'
        )
    ),
    'https://opensource-demo.orangehrmlive.com',
    1
FROM test_cases 
WHERE test_case_name = 'TC_PIM_001_addEmployeeValid';

INSERT INTO test_baselines (test_case_id, baseline_type, expected_value, description, version)
SELECT 
    test_case_id,
    'url',
    'https://opensource-demo.orangehrmlive.com/web/index.php/pim/viewPersonalDetails/empNumber/',
    'Expected PIM page after adding employee',
    1
FROM test_cases 
WHERE test_case_name = 'TC_PIM_001_addEmployeeValid';

-- =============================================================================
-- TC_PIM_002: Add Employee No Middle Name
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
        'defaults', JSON_OBJECT(
            'firstName', 'Yaser',
            'middleName', '',
            'lastName', 'Ayyad'
        )
    ),
    'https://opensource-demo.orangehrmlive.com',
    1
FROM test_cases 
WHERE test_case_name = 'TC_PIM_002_addEmployeeNoMiddleName';

INSERT INTO test_baselines (test_case_id, baseline_type, expected_value, description, version)
SELECT 
    test_case_id,
    'url',
    'https://opensource-demo.orangehrmlive.com/web/index.php/pim/viewPersonalDetails/empNumber/',
    'Expected PIM page after adding employee without middle name',
    1
FROM test_cases 
WHERE test_case_name = 'TC_PIM_002_addEmployeeNoMiddleName';

-- =============================================================================
-- TC_PIM_003: Missing First Name
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
        'defaults', JSON_OBJECT(
            'firstName', '',
            'middleName', 'Yaser',
            'lastName', 'Mohammad'
        )
    ),
    'https://opensource-demo.orangehrmlive.com',
    1
FROM test_cases 
WHERE test_case_name = 'TC_PIM_003_addEmployeeMissingFirstName';

INSERT INTO test_baselines (test_case_id, baseline_type, expected_value, description, version)
SELECT 
    test_case_id,
    'validation_message',
    'Required',
    'Expected validation for missing first name',
    1
FROM test_cases 
WHERE test_case_name = 'TC_PIM_003_addEmployeeMissingFirstName';

-- =============================================================================
-- TC_PIM_004: Missing Last Name
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
        'defaults', JSON_OBJECT(
            'firstName', 'Sama',
            'middleName', 'Yaser',
            'lastName', ''
        )
    ),
    'https://opensource-demo.orangehrmlive.com',
    1
FROM test_cases 
WHERE test_case_name = 'TC_PIM_004_addEmployeeMissingLastName';

INSERT INTO test_baselines (test_case_id, baseline_type, expected_value, description, version)
SELECT 
    test_case_id,
    'validation_message',
    'Required',
    'Expected validation for missing last name',
    1
FROM test_cases 
WHERE test_case_name = 'TC_PIM_004_addEmployeeMissingLastName';

-- =============================================================================
-- TC_PIM_005: Missing Both Names
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
        'defaults', JSON_OBJECT(
            'firstName', '',
            'middleName', '',
            'lastName', ''
        )
    ),
    'https://opensource-demo.orangehrmlive.com',
    1
FROM test_cases 
WHERE test_case_name = 'TC_PIM_005_addEmployeeMissingBoth';

INSERT INTO test_baselines (test_case_id, baseline_type, expected_value, description, version)
SELECT 
    test_case_id,
    'validation_message',
    'Required',
    'Expected validation for missing both names',
    1
FROM test_cases 
WHERE test_case_name = 'TC_PIM_005_addEmployeeMissingBoth';

-- =============================================================================
-- TC_PIM_006: Search By Valid Name
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
        'defaults', JSON_OBJECT(
            'firstName', 'name',
            'middleName', '',
            'lastName', 'Linda Anderson'
        )
    ),
    'https://opensource-demo.orangehrmlive.com',
    1
FROM test_cases 
WHERE test_case_name = 'TC_PIM_006_searchByValidName';

INSERT INTO test_baselines (test_case_id, baseline_type, expected_value, description, version)
SELECT 
    test_case_id,
    'url',
    'https://opensource-demo.orangehrmlive.com/web/index.php/pim/viewEmployeeList',
    'Expected employee list after search',
    1
FROM test_cases 
WHERE test_case_name = 'TC_PIM_006_searchByValidName';

-- =============================================================================
-- TC_PIM_007: Search By Invalid Name
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
        'defaults', JSON_OBJECT(
            'firstName', 'name',
            'middleName', '',
            'lastName', 'InvalidNameXYZ123'
        )
    ),
    'https://opensource-demo.orangehrmlive.com',
    1
FROM test_cases 
WHERE test_case_name = 'TC_PIM_007_searchByInvalidName';

INSERT INTO test_baselines (test_case_id, baseline_type, expected_value, description, version)
SELECT 
    test_case_id,
    'url',
    'https://opensource-demo.orangehrmlive.com/web/index.php/pim/viewEmployeeList',
    'Expected employee list with no records found',
    1
FROM test_cases 
WHERE test_case_name = 'TC_PIM_007_searchByInvalidName';

-- =============================================================================
-- TC_PIM_008: Search By Invalid ID
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
        'defaults', JSON_OBJECT(
            'firstName', 'id',
            'middleName', '',
            'lastName', '99999999'
        )
    ),
    'https://opensource-demo.orangehrmlive.com',
    1
FROM test_cases 
WHERE test_case_name = 'TC_PIM_008_searchByInvalidId';

INSERT INTO test_baselines (test_case_id, baseline_type, expected_value, description, version)
SELECT 
    test_case_id,
    'url',
    'https://opensource-demo.orangehrmlive.com/web/index.php/pim/viewEmployeeList',
    'Expected employee list with no records found',
    1
FROM test_cases 
WHERE test_case_name = 'TC_PIM_008_searchByInvalidId';

-- =============================================================================
-- Verification
-- =============================================================================

SELECT 
    '✓ PIM test data seeded successfully!' as status,
    (SELECT COUNT(*) FROM test_input_data WHERE test_case_id IN (SELECT test_case_id FROM test_cases WHERE test_case_name LIKE 'TC_PIM%')) as input_data_count,
    (SELECT COUNT(*) FROM test_baselines WHERE test_case_id IN (SELECT test_case_id FROM test_cases WHERE test_case_name LIKE 'TC_PIM%')) as baseline_count;

-- Show PIM test data summary
SELECT 
    tc.test_case_name,
    JSON_EXTRACT(ti.config_data, '$.defaults.firstName') as firstName,
    JSON_EXTRACT(ti.config_data, '$.defaults.middleName') as middleName,
    JSON_EXTRACT(ti.config_data, '$.defaults.lastName') as lastName,
    tb.baseline_type,
    LEFT(tb.expected_value, 50) as expected_value_preview
FROM test_cases tc
LEFT JOIN test_input_data ti ON tc.test_case_id = ti.test_case_id
LEFT JOIN test_baselines tb ON tc.test_case_id = tb.test_case_id
WHERE tc.test_case_name LIKE 'TC_PIM%'
ORDER BY tc.test_case_id;