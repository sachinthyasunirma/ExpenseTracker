//
//  AccountUnitTests.swift
//  ExpenseTrackerTests
//
//  Created by sachinthya sunirma rathnavibushana on 2025-05-07.
//

import XCTest
import Combine
@testable import ExpenseTracker

final class AccountViewModelTests: XCTestCase {

    var viewModel: AccountViewModel!
    var mockService: MockAccountService!
    var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        mockService = MockAccountService()
        viewModel = AccountViewModel(accountService: mockService)
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables.removeAll()
        super.tearDown()
    }

    func testLoadAccounts_success() async {
        let dummyAccount = Account(context: CoreDataService.shared.context)
        dummyAccount.id = UUID()
        dummyAccount.name = "Sample"
        dummyAccount.type = "Cash"
        dummyAccount.currency = "USD"
        dummyAccount.initialBalance = 100
        dummyAccount.currentBalance = 100
        dummyAccount.createdAt = Date()
        dummyAccount.updatedAt = Date()
        dummyAccount.isActive = true

        mockService.testAccounts = [dummyAccount]

        await viewModel.loadAccounts()
        XCTAssertFalse(viewModel.accounts.isEmpty)
        XCTAssertEqual(viewModel.accounts.first?.name, "Sample")
    }

    func testCreateAccount_success() async {
        let name = "Test Account"
        let type = "Cash"
        let currency = "USD"
        let balance: Decimal = 100.0

        await viewModel.createAccount(name: name, type: type, currency: currency, initialBalance: balance)

        XCTAssertEqual(viewModel.accounts.count, 1)
        XCTAssertEqual(viewModel.accounts.first?.name, name)
        XCTAssertEqual(viewModel.accounts.first?.initialBalance?.decimalValue, balance)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testDeleteAccount_success() async {
        // First, create an account
        await viewModel.createAccount(name: "To Delete", type: "Bank", currency: "USD", initialBalance: 500)
        guard let id = viewModel.accounts.first?.id else {
            XCTFail("No account to delete")
            return
        }

        await viewModel.deleteAccount(id: id)
        XCTAssertTrue(viewModel.accounts.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testUpdateAccountStatus_success() async {
        await viewModel.createAccount(name: "Active Account", type: "Cash", currency: "USD", initialBalance: 300)
        guard let id = viewModel.accounts.first?.id else {
            XCTFail("No account to update")
            return
        }

        await viewModel.updateAccountStatus(id: id, isActive: false)

        XCTAssertFalse(viewModel.accounts.first!.isActive)
    }

    func testLoadAccounts_failure() async {
        mockService.shouldFail = true
        await viewModel.loadAccounts()
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.accounts.isEmpty)
    }
}
