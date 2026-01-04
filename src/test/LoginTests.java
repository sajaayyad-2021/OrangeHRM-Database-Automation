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
public class LoginTests extends BaseTemplate {

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
    public void LoginSuite() throws IOException, InterruptedException {

        if (testNmaes_login == null || testNmaes_login.trim().isEmpty()) {
            throw new SkipException("Skipping LoginTests — no -testNmaes_login argument provided.");
        }

        extent = ExtentManager.getInstance();
        String className = this.getClass().getSimpleName();
        
        // Initialize Database DAOs
        testDataDAO = BaseTemplate.testDataDAO;
        testResultDAO = BaseTemplate.testResultDAO;
        executionId = BaseTemplate.executionId;

        testNmaes_login = testNmaes_login.trim();

        // Auto Discovery or Specific Tests
        if ("ALL".equalsIgnoreCase(testNmaes_login)) {
            testsList = new String[]{
                "TC_LOG_001_validLogin",
                "TC_LOG_003_emptyFields",
                "TC_LOG_004_emptyPasswordOnly",
                "TC_LOG_008_invalidBoth",
                "TC_LOG_009_logoutRedirect"
            };
            System.out.println("[LoginTests] Discovered tests: " + Arrays.toString(testsList));
        } else {
            testsList = Arrays.stream(testNmaes_login.split(","))
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .toArray(String[]::new);
            System.out.println("[LoginTests] Running selected tests: " + Arrays.toString(testsList));
        }

        // Test Loop
        for (String testcase : testsList) {

            activeTest = testcase;
            addCurrentTestMthod(activeTest);

            currentTest = extent.createTest(activeTest);
            currentTest.assignCategory("Regression");
            currentTest.assignCategory("Login");
            currentTest.info("Starting test: " + activeTest);

            try {
                System.out.println("\n[DATABASE MODE] Loading config from database");
                
                // Load config from database
                Config cfg = testDataDAO.getTestConfiguration(className, testcase);
                
                if (cfg == null) {
                    currentTest.fail("Test configuration not found in database");
                    throw new RuntimeException("Test configuration not found: " + testcase);
                }
                
                System.out.println("SUCCESS: Config loaded from database: " + testcase);
                
                mf = new MainFunctions(driver, cfg);

                general(cfg, className, testcase);

                currentTest.pass("Test completed");

            } catch (Throwable e) {
                currentTest.fail("Exception: " + e.getMessage());
                currentTest.fail(e);
                e.printStackTrace();
            }
        }

        extent.flush();
    }

    private void general(Config cfg, String className, String testCaseName) {

        long startTime = System.currentTimeMillis();
        
        try {
            currentTest.info("Executing: " + testCaseName);

            mf.performLogin(cfg);

            String actualResult = getActualLoginResult();
            currentTest.info("Actual Result: " + actualResult);

            // Get test case ID
            int testCaseId = testDataDAO.getTestCaseId(className, testCaseName);
            
            // Get expected baseline from database
            String expectedBaseline = testDataDAO.getExpectedBaseline(testCaseId, "url");
            if (expectedBaseline == null) {
                expectedBaseline = testDataDAO.getExpectedBaseline(testCaseId, "validation_message");
            }
            if (expectedBaseline == null) {
                expectedBaseline = testDataDAO.getExpectedBaseline(testCaseId, "alert_message");
            }
            
            // Compare results
            boolean match = actualResult != null && actualResult.contains(expectedBaseline);
            String result = match ? "PASS" : "FAIL";
            
            // Calculate duration
            long duration = System.currentTimeMillis() - startTime;
            
            // Get baseline ID
            int baselineId = testResultDAO.getBaselineIdForTest(testCaseId, "url");
            if (baselineId == -1) {
                baselineId = testResultDAO.getBaselineIdForTest(testCaseId, "validation_message");
            }
            if (baselineId == -1) {
                baselineId = testResultDAO.getBaselineIdForTest(testCaseId, "alert_message");
            }
            
            // Save result to database
            int resultId = testResultDAO.saveTestResult(
                executionId, testCaseId, baselineId,
                actualResult, expectedBaseline, result,
                null, duration, null
            );
            
            // Save baseline comparison
            if (baselineId > 0) {
                testResultDAO.saveBaselineComparison(
                    resultId, baselineId,
                    expectedBaseline, actualResult,
                    "EXPECTED: " + expectedBaseline + "\nACTUAL: " + actualResult + "\nRESULT: " + result,
                    match ? "MATCH" : "MISMATCH"
                );
            }
            
            // Update ExtentReports
            currentTest.info(MarkupHelper.createCodeBlock(
                "EXPECTED:\n" + expectedBaseline +
                "\n\nACTUAL:\n" + actualResult +
                "\n\nRESULT: " + result
            ));

            if (match) {
                currentTest.pass("✓ Actual matches Expected");
            } else {
                currentTest.fail("✗ Baseline mismatch");
            }

        } catch (Exception e) {
            currentTest.fail("Exception: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private String getActualLoginResult() {

        try {
            if (mf.isDashboard()) return "https://opensource-demo.orangehrmlive.com/web/index.php/dashboard/index";
            if (mf.hasInvalidCredentialsError()) return "Invalid credentials";
            if (mf.hasRequiredValidation()) return "Required";
            if (mf.isOnLoginPage()) return "https://opensource-demo.orangehrmlive.com/web/index.php/auth/login";

            return mf.getCurrentURL();

        } catch (Exception e) {
            return "ERROR: " + e.getMessage();
        }
    }
}