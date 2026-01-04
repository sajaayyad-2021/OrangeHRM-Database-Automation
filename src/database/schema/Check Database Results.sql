USE orangehrm_test_db;

-- Latest execution summary
SELECT 
    execution_id,
    browser,
    started_at,
    completed_at,
    TIMESTAMPDIFF(SECOND, started_at, completed_at) as duration_seconds,
    total_tests,
    passed_tests,
    failed_tests,
    status
FROM test_executions 
ORDER BY execution_id DESC 
LIMIT 1;

-- All test results
SELECT 
    tc.test_case_name,
    tr.comparison_result,
    tr.duration_ms,
    ROUND(tr.duration_ms / 1000.0, 2) as duration_seconds
FROM test_results tr
JOIN test_cases tc ON tr.test_case_id = tc.test_case_id
WHERE tr.execution_id = (SELECT MAX(execution_id) FROM test_executions)
ORDER BY tr.started_at;

-- Pass rate by suite
SELECT 
    ts.suite_name,
    COUNT(tr.result_id) as total_runs,
    SUM(CASE WHEN tr.comparison_result = 'PASS' THEN 1 ELSE 0 END) as passes,
    SUM(CASE WHEN tr.comparison_result = 'FAIL' THEN 1 ELSE 0 END) as fails,
    ROUND(SUM(CASE WHEN tr.comparison_result = 'PASS' THEN 1 ELSE 0 END) * 100.0 / COUNT(tr.result_id), 2) as pass_rate
FROM test_suites ts
JOIN test_cases tc ON ts.suite_id = tc.suite_id
JOIN test_results tr ON tc.test_case_id = tr.test_case_id
WHERE tr.execution_id = (SELECT MAX(execution_id) FROM test_executions)
GROUP BY ts.suite_name;