package test;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.*;

import org.testng.SkipException;
import org.testng.annotations.Listeners;
import org.testng.annotations.Test;

import com.aventstack.extentreports.*;
import com.aventstack.extentreports.markuputils.MarkupHelper;

import database.TestDataDAO;
import database.TestResultDAO;
import reporting.ExtentManager;
import testbase.BaseTemplate;
import utilites.Config;

import utilites.MainFunctions;

@Listeners(reporting.ExtentTestNGITestListener.class)
public class PIMTests extends BaseTemplate {

    MainFunctions mf;
    private static ExtentReports extent;
    private ExtentTest currentTest;
    
    // Database objects
    private static TestDataDAO testDataDAO;
    private static TestResultDAO testResultDAO;
    private static int executionId;

    String[] testsList = null;
    String activeTest = null;

    @Test
    public void PIMSuite() throws IOException, InterruptedException {

        if (testNmaes_pim == null || testNmaes_pim.trim().isEmpty()) {
            throw new SkipException("Skipping PIMTests — no -testNmaes_pim argument provided.");
        }

        extent = ExtentManager.getInstance();
        String className = this.getClass().getSimpleName();
        
        // Initialize Database DAOs
        testDataDAO = BaseTemplate.testDataDAO;
        testResultDAO = BaseTemplate.testResultDAO;
        executionId = BaseTemplate.executionId;

        testNmaes_pim = testNmaes_pim.trim();

        if ("ALL".equalsIgnoreCase(testNmaes_pim)) {
            testsList = new String[]{
                "TC_PIM_001_addEmployeeValid",
                "TC_PIM_002_addEmployeeNoMiddleName",
                "TC_PIM_003_addEmployeeMissingFirstName",
                "TC_PIM_004_addEmployeeMissingLastName",
                "TC_PIM_005_addEmployeeMissingBoth",
                "TC_PIM_006_searchByValidName",
                "TC_PIM_007_searchByInvalidName",
                "TC_PIM_008_searchByInvalidId"
            };
        } else {
            testsList = Arrays.stream(testNmaes_pim.split(","))
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .toArray(String[]::new);
        }

        if (testsList == null || testsList.length == 0) {
            throw new SkipException("No PIM test cases found.");
        }

        // LOGIN ONCE - Load from database
        System.out.println("\n[DATABASE MODE] Loading login config from database");
        Config loginCfg = testDataDAO.getTestConfiguration("LoginTests", "TC_LOG_001_validLogin");
        
        if (loginCfg == null) {
            throw new RuntimeException("Login configuration not found in database");
        }
        
        mf = new MainFunctions(driver, loginCfg);
        mf.performLoginWithoutLogout(loginCfg);  
        System.out.println("[PIMSuite] Logged in successfully");

        // Test Loop
        for (String tc : testsList) {

            activeTest = tc;
            addCurrentTestMthod(activeTest);

            currentTest = extent.createTest(activeTest);
            currentTest.assignCategory("Regression");
            currentTest.assignCategory("PIM");
            currentTest.info("Starting test: " + activeTest);

            try {
                System.out.println("\n[DATABASE MODE] Loading config from database");
                
                Config cfg = testDataDAO.getTestConfiguration(className, tc);
                
                if (cfg == null) {
                    currentTest.fail("Test configuration not found in database");
                    throw new RuntimeException("Test configuration not found: " + tc);
                }
                
                System.out.println("SUCCESS: Config loaded from database: " + tc);
                
                mf = new MainFunctions(driver, cfg);

                general(cfg, className, tc);

                currentTest.pass("Test completed");

            } catch (Throwable e) {
                currentTest.fail("Exception occurred: " + e.getMessage());
                currentTest.fail(e);
            }
        }

        extent.flush();
    }

    private void general(Config cfg, String className, String testCaseName) {

        long startTime = System.currentTimeMillis();
        
        try {
            currentTest.info("Executing test: " + testCaseName);

            String actionType = determineActionType(testCaseName);
            currentTest.info("Action type: " + actionType);

            if (actionType.equals("addEmployee")) {
                mf.performAddEmployee(cfg);
            } else if (actionType.equals("searchEmployee")) {
                mf.performSearchEmployee(cfg);
            }

            String actualResult = mf.getCurrentURL();
            currentTest.info("Actual Result: " + actualResult);

            // Get test case ID
            int testCaseId = testDataDAO.getTestCaseId(className, testCaseName);
            
            // Get expected baseline
            String expectedBaseline = testDataDAO.getExpectedBaseline(testCaseId, "url");
            if (expectedBaseline == null) {
                expectedBaseline = testDataDAO.getExpectedBaseline(testCaseId, "validation_message");
            }
            
            // Compare
            boolean match = actualResult != null && actualResult.contains(expectedBaseline);
            String result = match ? "PASS" : "FAIL";
            long duration = System.currentTimeMillis() - startTime;
            
            // Get baseline ID
            int baselineId = testResultDAO.getBaselineIdForTest(testCaseId, "url");
            if (baselineId == -1) {
                baselineId = testResultDAO.getBaselineIdForTest(testCaseId, "validation_message");
            }
            
            // Save to database
            int resultId = testResultDAO.saveTestResult(
                executionId, testCaseId, baselineId,
                actualResult, expectedBaseline, result,
                null, duration, null
            );
            
            if (baselineId > 0) {
                testResultDAO.saveBaselineComparison(
                    resultId, baselineId,
                    expectedBaseline, actualResult,
                    "EXPECTED: " + expectedBaseline + "\nACTUAL: " + actualResult + "\nRESULT: " + result,
                    match ? "MATCH" : "MISMATCH"
                );
            }
            
            currentTest.info(MarkupHelper.createCodeBlock(
                "EXPECTED:\n" + expectedBaseline +
                "\n\nACTUAL:\n" + actualResult +
                "\n\nRESULT: " + result
            ));

            if (match) currentTest.pass("✓ Actual matches Expected");
            else currentTest.fail("✗ Baseline mismatch");

        } catch (Exception e) {
            currentTest.fail("Exception: " + e.getMessage());
        }
    }

    private String determineActionType(String testName) {
        String lower = testName.toLowerCase();
        if (lower.contains("addemployee")) return "addEmployee";
        if (lower.contains("search")) return "searchEmployee";
        return "unknown";
    }
}