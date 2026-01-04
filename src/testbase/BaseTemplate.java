package testbase;

import java.lang.reflect.Method;
import java.time.Duration;
import java.util.LinkedHashSet;
import java.util.Set;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.testng.annotations.AfterSuite;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.BeforeSuite;

import com.aventstack.extentreports.ExtentReports;

import database.DatabaseManager;
import database.TestDataDAO;
import database.TestResultDAO;
import reporting.ExtentManager;
import utilites.Config;

public class BaseTemplate {

    // -------------------- WebDriver & Wait --------------------
    public static WebDriver driver;
    protected static WebDriverWait wait;

    // -------------------- Database Integration --------------------
    protected static TestDataDAO testDataDAO;
    protected static TestResultDAO testResultDAO;
    protected static int executionId = -1;

    // -------------------- Config / CLI properties --------------------
    protected static String browser;        
    protected static String url = "";       
    protected static String xml;

    // -------------------- ROOT PATH (deprecated - kept for compatibility) --------------------
    public static String SuitePath;
    protected static ExtentReports extent;
    
    // -------------------- Test Flags --------------------
    public static String testNmaes_login;
    public static String testNmaes_pim; 
    public static String testNmaes_leave;

    // -------------------- Test tracking --------------------
    protected static final Set<String> CURRENT_TEST_NAME = new LinkedHashSet<>();

    // ========================================================================
    // Static initializer - loads properties from System properties (Maven -D args)
    static {
        initFromSystemProperties();
    }

    // Initialize from System properties (for Maven command line)
    private static void initFromSystemProperties() {
        SuitePath       = System.getProperty("suitePath", "artifacts");
        browser         = System.getProperty("browser", "chrome");
        url             = System.getProperty("url", "");
        xml             = System.getProperty("xmlFile", "testng.xml");
        
        testNmaes_login = System.getProperty("testNmaes_login", "ALL");
        testNmaes_pim   = System.getProperty("testNmaes_pim", "ALL");
        testNmaes_leave = System.getProperty("testNmaes_leave", "ALL");
        
        System.out.println("=== BaseTemplate Configuration ===");
        System.out.println("Browser: " + browser);
        System.out.println("URL: " + url);
        System.out.println("XML File: " + xml);
        System.out.println("testNmaes_login: " + testNmaes_login);
        System.out.println("testNmaes_pim: " + testNmaes_pim);
        System.out.println("testNmaes_leave: " + testNmaes_leave);
        System.out.println("Database Mode: ENABLED");
        System.out.println("==================================");
    }

    // CLI args (for JAR execution) - kept for backward compatibility
    public static void Setargs(String[] args) {
        SuitePath       = getArgs(args, "-out",             System.getProperty("suitePath", "artifacts"));
        browser         = getArgs(args, "-browser",         System.getProperty("browser", "chrome"));
        
        testNmaes_login = getArgs(args, "-testNmaes_login", System.getProperty("testNmaes_login", "ALL"));
        testNmaes_pim   = getArgs(args, "-testNmaes_pim",   System.getProperty("testNmaes_pim", "ALL"));
        testNmaes_leave = getArgs(args, "-testNmaes_leave", System.getProperty("testNmaes_leave", "ALL"));
        
        xml             = getArgs(args, "-xml",             System.getProperty("xmlFile", "testng.xml"));
        url             = getArgs(args, "-url",             System.getProperty("url", ""));
    }

    private static String getArgs(String[] args, String key, String def) {
        if (args == null)
            return def;

        for (int i = 0; i < args.length - 1; i++) {
            if (args[i].equals(key)) {
                return args[i + 1];
            }
        }
        return def;
    }

    // ========================================================================
    // DATABASE INTEGRATION
    // ========================================================================
    
    /**
     * Load test configuration from database
     * Replaces: CustomFunction.loadConfig(configPath)
     */
    protected static Config loadthisTestConfig(String className, String testName) {
        try {
            Config config = testDataDAO.getTestConfiguration(className, testName);
            
            if (config == null) {
                System.err.println("ERROR: Config not found in database: " + className + "/" + testName);
                throw new RuntimeException("Test configuration not found in database");
            }
            
            System.out.println("SUCCESS: Config loaded from database: " + testName);
            return config;
            
        } catch (Exception e) {
            System.err.println("ERROR: Error loading config from database: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to load test configuration", e);
        }
    }
    
    /**
     * Overload for backward compatibility
     */
    protected static Config loadthisTestConfig(String className) {
        System.err.println("WARNING: loadthisTestConfig(className) is deprecated");
        return null;
    }

    // ========================================================================
    // DEPRECATED PATH HELPERS (kept for compatibility but not used)
    // ========================================================================
    
    @Deprecated
    public static String testCaseRoot(String className, String testName) {
        return SuitePath + "\\TestCases\\" + className + "\\" + testName + "\\";
    }
    
    @Deprecated
    public static String inputPath(String className, String testName) {
        return testCaseRoot(className, testName) + "Input\\";
    }

    @Deprecated
    public static String actualPath(String className, String testName) {
        return testCaseRoot(className, testName) + "Actual\\";
    }

    @Deprecated
    public static String expectedPath(String className, String testName) {
        return testCaseRoot(className, testName) + "Expected\\";
    }

    @Deprecated
    public static String diffPath(String className, String testName) {
        return testCaseRoot(className, testName) + "Diff\\";
    }

    // ========================================================================
    // TEST TRACKING
    // ========================================================================
    
    protected static void addCurrentTestMthod(String method) {
        CURRENT_TEST_NAME.add(method);
    }

    protected static String currentTestMethod() {
        String last = null;
        for (String m : CURRENT_TEST_NAME)
            last = m;
        return last == null ? "unknownTest" : last;
    }

    // ========================================================================
    // TESTNG LIFECYCLE
    // ========================================================================
    
    @BeforeSuite
    public void beforeSuiteSetup() {
        
        System.out.println("\n========================================");
        System.out.println("    STARTING TEST EXECUTION");
        System.out.println("========================================\n");
        
        // -------------------- Initialize Database --------------------
        try {
            testDataDAO = new TestDataDAO();
            testResultDAO = new TestResultDAO();
            
            // Create execution record
            executionId = testResultDAO.createExecution(browser, "staging");
            
            System.out.println("SUCCESS: Database initialized successfully");
            System.out.println("SUCCESS: Execution ID: " + executionId + "\n");
            
        } catch (Exception e) {
            System.err.println("ERROR: Database initialization failed!");
            e.printStackTrace();
            throw new RuntimeException("Database initialization failed", e);
        }
        
        // -------------------- Initialize WebDriver --------------------
        try {
            driver = new ChromeDriver();
            driver.manage().window().maximize();
            wait = new WebDriverWait(driver, Duration.ofSeconds(10));
            
            System.out.println("SUCCESS: WebDriver initialized: Chrome");
            
        } catch (Exception e) {
            System.err.println("ERROR: WebDriver initialization failed!");
            e.printStackTrace();
            throw new RuntimeException("WebDriver initialization failed", e);
        }
        
        // -------------------- Initialize ExtentReports --------------------
        extent = ExtentManager.getInstance();
        System.out.println("SUCCESS: ExtentReports initialized\n");

        // -------------------- Navigate to URL --------------------
        if (url != null && !url.isEmpty()) {
            driver.get(url);
            System.out.println("SUCCESS: Navigated to: " + url + "\n");
        }
        
        System.out.println("========================================\n");
    }

    @BeforeMethod
    public void getMethodname(Method method) {
        addCurrentTestMthod(method.getName());
    }

    @AfterSuite
    public void afterSuiteCleanup() {
        
        System.out.println("\n========================================");
        System.out.println("    FINALIZING TEST EXECUTION");
        System.out.println("========================================\n");
        
        // -------------------- Finalize Execution --------------------
        if (executionId > 0 && testResultDAO != null) {
            try {
                // Note: Pass counts should be tracked in test classes
                // For now, just mark as completed
                testResultDAO.finalizeExecution(executionId, 0, 0, 0);
                System.out.println("SUCCESS: Test execution finalized (ID: " + executionId + ")");
                
            } catch (Exception e) {
                System.err.println("WARNING: Error finalizing execution: " + e.getMessage());
            }
        }
        
        // -------------------- Close Database Connection --------------------
        try {
            DatabaseManager.getInstance().closeConnection();
            System.out.println("SUCCESS: Database connection closed");
            
        } catch (Exception e) {
            System.err.println("WARNING: Error closing database: " + e.getMessage());
        }
        
        // -------------------- Close WebDriver --------------------
        try {
            if (driver != null) {
                driver.quit();
                System.out.println("SUCCESS: WebDriver closed");
            }
        } catch (Exception e) {
            System.err.println("WARNING: Error closing WebDriver: " + e.getMessage());
        }
        
        System.out.println("\n========================================");
        System.out.println("    TEST EXECUTION COMPLETED");
        System.out.println("========================================\n");
    }
}