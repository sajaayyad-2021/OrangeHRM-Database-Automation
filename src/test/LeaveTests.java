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
public class LeaveTests extends BaseTemplate {

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
    public void LeaveSuite() throws IOException, InterruptedException {

        if (testNmaes_leave == null || testNmaes_leave.trim().isEmpty()) {
            throw new SkipException("Skipping LeaveTests — no -testNmaes_leave argument provided.");
        }

        extent = ExtentManager.getInstance();
        String className = this.getClass().getSimpleName();
        
        // Initialize Database DAOs
        testDataDAO = BaseTemplate.testDataDAO;
        testResultDAO = BaseTemplate.testResultDAO;
        executionId = BaseTemplate.executionId;

        testNmaes_leave = testNmaes_leave.trim();

        if ("ALL".equalsIgnoreCase(testNmaes_leave)) {
            testsList = new String[]{
                "TC_LEAVE_001_basicSearch",
                "TC_LEAVE_002_searchWithEmployeeName",
                "TC_LEAVE_003_invalidDateToDate",
                "TC_LEAVE_004_selectLeaveStatus",
                "TC_LEAVE_005_selectLeaveType",
                "TC_LEAVE_006_resetButton"
            };
        } else {
            testsList = testNmaes_leave.split(",");
        }

        // Login once - Load from database
        System.out.println("\n[DATABASE MODE] Loading login config from database");
        Config loginCfg = testDataDAO.getTestConfiguration("LoginTests", "TC_LOG_001_validLogin");
        
        if (loginCfg == null) {
            throw new RuntimeException("Login configuration not found in database");
        }
        
        mf = new MainFunctions(driver, loginCfg);
        mf.performLoginWithoutLogout(loginCfg);

        System.out.println("[LeaveSuite] Logged in successfully");

        for (String tc : testsList) {

            activeTest = tc;
            addCurrentTestMthod(activeTest);

            currentTest = extent.createTest(activeTest);
            currentTest.assignCategory("Regression");
            currentTest.assignCategory("Leave");

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
                currentTest.fail("Exception: " + e.getMessage());
                e.printStackTrace();
            }
        }

        extent.flush();
    }

    private void general(Config cfg, String className, String testCaseName) {

        long startTime = System.currentTimeMillis();
        
        try {
            currentTest.info("Executing: " + testCaseName);

            mf.performLeaveSearch(cfg);

            String actualResult = mf.getCurrentURL();
            currentTest.info("Actual: " + actualResult);

            // Get test case ID
            int testCaseId = testDataDAO.getTestCaseId(className, testCaseName);
            
            // Get expected baseline
            String expectedBaseline = testDataDAO.getExpectedBaseline(testCaseId, "url");
            
            // Compare
            boolean match = actualResult != null && actualResult.contains(expectedBaseline);
            String result = match ? "PASS" : "FAIL";
            long duration = System.currentTimeMillis() - startTime;
            
            // Get baseline ID
            int baselineId = testResultDAO.getBaselineIdForTest(testCaseId, "url");
            
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

            if (match) currentTest.pass("✓ Actual matches expected");
            else currentTest.fail("✗ Baseline mismatch");

        } catch (Exception ex) {
            currentTest.fail("Artifact error: " + ex.getMessage());
        }
    }
}