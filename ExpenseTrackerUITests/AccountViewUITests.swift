//
//  AccountViewUITests.swift
//  ExpenseTrackerUITests
//
//  Created by sachinthya sunirma rathnavibushana on 2025-05-07.
//

import XCTest
@testable import ExpenseTracker

class AccountViewUITests: XCTestCase {
    var app: XCUIApplication!
    var viewModel: AccountViewModel!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        viewModel = AccountViewModel()
        app.launchArguments.append("--uitesting")
        app.launch()
    }
    
    override func tearDown() {
        app = nil
        viewModel = nil
        super.tearDown()
    }
    
    func testAccountViewInitialState() {
        navigateToAccountView()
        
        XCTAssertTrue(app.staticTexts["Add New Account"].exists)
        XCTAssertTrue(app.buttons["Back"].exists)
        
        XCTAssertTrue(app.otherElements["CardPreview"].exists)
        XCTAssertTrue(app.staticTexts["Rs"].exists)
        XCTAssertTrue(app.staticTexts["0.00"].exists)
        
        XCTAssertTrue(app.staticTexts["Account Information"].exists)
        XCTAssertTrue(app.textFields["Enter account name"].exists)
        XCTAssertTrue(app.staticTexts["Account Type"].exists)
        XCTAssertTrue(app.staticTexts["Savings"].exists) // Default value
        XCTAssertTrue(app.staticTexts["Currency"].exists)
        XCTAssertTrue(app.staticTexts["LKR"].exists) // Default value
        XCTAssertTrue(app.staticTexts["Amount"].exists)
        XCTAssertTrue(app.textFields["0.00"].exists)
        
        let saveButton = app.buttons["Create Account"]
        XCTAssertTrue(saveButton.exists)
        XCTAssertFalse(saveButton.isEnabled)
    }
    
    func testAccountCreationFlow() {
        navigateToAccountView()
        
        let accountNameField = app.textFields["Enter account name"]
        accountNameField.tap()
        accountNameField.typeText("Test Account")
        
        app.staticTexts["Savings"].tap()
        app.buttons["Credit Card"].tap()
        
        app.staticTexts["LKR"].tap()
        app.buttons["USD"].tap()
        
        let amountField = app.textFields["0.00"]
        amountField.tap()
        amountField.typeText("100.50")
        
        let saveButton = app.buttons["Create Account"]
        XCTAssertTrue(saveButton.isEnabled)
        
        saveButton.tap()
        
    }
    
    func testInvalidAccountCreation() {
        navigateToAccountView()
        
        let saveButton = app.buttons["Create Account"]
        XCTAssertFalse(saveButton.isEnabled)
        
        let accountNameField = app.textFields["Enter account name"]
        accountNameField.tap()
        accountNameField.typeText("Test Account")
        
        XCTAssertTrue(saveButton.isEnabled)
        
        accountNameField.tap()
        accountNameField.buttons["Clear text"].tap()
        
        XCTAssertFalse(saveButton.isEnabled)
    }
    
    func testCurrencyFormatting() {
        navigateToAccountView()
        
        app.staticTexts["LKR"].tap()
        app.buttons["USD"].tap()
        
        XCTAssertTrue(app.staticTexts["$"].exists)
        
        let amountField = app.textFields["0.00"]
        amountField.tap()
        amountField.typeText("1234.56")
        
        XCTAssertTrue(app.staticTexts["1,234.56"].exists)
    }
    
    func testAccountTypeSelection() {
        navigateToAccountView()
        
        XCTAssertTrue(app.staticTexts["Savings"].exists)
        
        app.staticTexts["Savings"].tap()
        
        for type in ["Checking", "Savings", "Credit Card", "Cash", "Investment", "Expense"] {
            XCTAssertTrue(app.buttons[type].exists)
        }
        
        app.buttons["Cash"].tap()
        
        XCTAssertTrue(app.staticTexts["Cash"].exists)
    }
    
    private func navigateToAccountView() {
        app.buttons["Add Account"].tap()
    }
}
