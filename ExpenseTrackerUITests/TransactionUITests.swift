//
//  TransactionUITests.swift
//  ExpenseTrackerUITests
//
//  Created by sachinthya sunirma rathnavibushana on 2025-05-07.
//

import XCTest

class TransactionUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        
        // Launch with test configuration
        app.launchArguments.append("--uitesting")
        app.launch()
    }
    
    override func tearDown() {
        app = nil
        super.tearDown()
    }
    
    func testTransactionListLoading() {
        // Given: App is launched with test data
        navigateToTransactions()
        
        // Then: Verify loading state
        let loadingIndicator = app.activityIndicators["LoadingIndicator"]
        XCTAssertTrue(loadingIndicator.exists, "Loading indicator should be visible")
        
        // Wait for loading to complete
        let firstTransaction = app.staticTexts["TransactionItem_0"]
        expectation(for: NSPredicate(format: "exists == true"), evaluatedWith: firstTransaction, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        // Verify transactions are displayed
        XCTAssertTrue(firstTransaction.exists, "Transactions should be displayed after loading")
    }
    
    func testTransactionListErrorState() {
        // Given: App is launched with error state
        app.launchArguments.append("--mock-error")
        app.launch()
        
        navigateToTransactions()
        
        // Then: Verify error state
        let errorAlert = app.alerts["Error"]
        XCTAssertTrue(errorAlert.exists, "Error alert should be displayed")
        
        let okButton = errorAlert.buttons["OK"]
        XCTAssertTrue(okButton.exists, "OK button should be available")
        
        okButton.tap()
        XCTAssertFalse(errorAlert.exists, "Error alert should be dismissed")
    }
    
    func testAddTransactionFlow() {
        // Given: App is launched
        navigateToTransactions()
        
        // When: Tap add button
        let addButton = app.buttons["AddTransactionButton"]
        XCTAssertTrue(addButton.exists, "Add button should exist")
        addButton.tap()
        
        // Then: Verify add transaction form appears
        let amountField = app.textFields["AmountField"]
        XCTAssertTrue(amountField.exists, "Amount field should exist")
        
        let descriptionField = app.textFields["DescriptionField"]
        XCTAssertTrue(descriptionField.exists, "Description field should exist")
        
        let saveButton = app.buttons["SaveTransactionButton"]
        XCTAssertTrue(saveButton.exists, "Save button should exist")
        
        // Fill out the form
        amountField.tap()
        amountField.typeText("100.00")
        
        descriptionField.tap()
        descriptionField.typeText("Test Transaction")
        
        // Save the transaction
        saveButton.tap()
        
        // Verify new transaction appears in list
        let newTransaction = app.staticTexts["Test Transaction"]
        expectation(for: NSPredicate(format: "exists == true"), evaluatedWith: newTransaction, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertTrue(newTransaction.exists, "New transaction should appear in list")
    }
    
    func testDeleteTransaction() {
        // Given: App is launched with test data
        navigateToTransactions()
        
        // Wait for transactions to load
        let firstTransaction = app.staticTexts["TransactionItem_0"]
        expectation(for: NSPredicate(format: "exists == true"), evaluatedWith: firstTransaction, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        // When: Swipe to delete
        firstTransaction.swipeLeft()
        
        let deleteButton = app.buttons["Delete"]
        XCTAssertTrue(deleteButton.exists, "Delete button should appear")
        deleteButton.tap()
        
        // Then: Verify transaction is removed
        expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: firstTransaction, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertFalse(firstTransaction.exists, "Transaction should be deleted")
    }
    
    func testMonthlyFilter() {
        // Given: App is launched with test data
        navigateToTransactions()
        
        // When: Tap filter button
        let filterButton = app.buttons["FilterButton"]
        XCTAssertTrue(filterButton.exists, "Filter button should exist")
        filterButton.tap()
        
        // Select month filter
        let monthPicker = app.pickers["MonthPicker"]
        XCTAssertTrue(monthPicker.exists, "Month picker should exist")
        
        // May 2023 (assuming test data is for this month)
        monthPicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "May")
        monthPicker.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "2023")
        
        let applyButton = app.buttons["ApplyFilterButton"]
        XCTAssertTrue(applyButton.exists, "Apply button should exist")
        applyButton.tap()
        
        // Then: Verify filtered transactions
        let filteredTransaction = app.staticTexts["MayTransaction"]
        expectation(for: NSPredicate(format: "exists == true"), evaluatedWith: filteredTransaction, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertTrue(filteredTransaction.exists, "Filtered transaction should appear")
    }
    
    private func navigateToTransactions() {
        // Assuming we need to navigate from a main screen to transactions
        let accountsButton = app.buttons["AccountsButton"]
        if accountsButton.exists {
            accountsButton.tap()
        }
        
        let testAccount = app.buttons["Account_\(UUID().uuidString)"]
        if testAccount.exists {
            testAccount.tap()
        }
    }
}
