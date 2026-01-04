-- =============================================================================
-- Seed Test Suites
-- =============================================================================

USE orangehrm_test_db;

INSERT INTO test_suites (suite_name, description, is_active) VALUES
('LoginTests', 'Login functionality test suite - validates authentication flows', TRUE),
('PIMTests', 'PIM module test suite - validates employee management operations', TRUE),
('LeaveTests', 'Leave management test suite - validates leave search and filtering', TRUE)
ON DUPLICATE KEY UPDATE 
    description = VALUES(description),
    is_active = VALUES(is_active),
    updated_at = CURRENT_TIMESTAMP;

-- Verification
SELECT 
    '✓ Test suites seeded successfully!' as status,
    COUNT(*) as total_suites
FROM test_suites;

SELECT * FROM test_suites ORDER BY suite_id;