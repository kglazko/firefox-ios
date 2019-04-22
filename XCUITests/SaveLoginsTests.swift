/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

let domain = "http://localhost:\(serverPort)"
let domainLogin = "test@example.com"
let domainSecondLogin = "test2@example.com"
let testLoginPage = path(forTestPage: "test-password.html")
let testSecondLoginPage = path(forTestPage: "test-password-2.html")
let savedLoginEntry = "test@example.com, http://localhost:\(serverPort)"
let urlLogin = path(forTestPage:"empty-login-form.html")
let mailLogin = "iosmztest@mailinator.com"
//The following seem to be labels that change a lot and make the tests break; aka volatile. Let's keep them in one place.
let loginsListURLLabel = "Website, \(domain)"
let loginsListUsernameLabel = "Username, test@example.com"
let loginsListPasswordLabel = "Password"
let defaultNumRowsLoginsList = 2
let defaultNumRowsEmptyFilterList = 0

class SaveLoginTest: BaseTestCase {

    private func saveLogin(givenUrl: String) {
        navigator.openURL(givenUrl)
        waitUntilPageLoad()
        waitForExistence(app.buttons["submit"], timeout: 3)
        app.buttons["submit"].tap()
        app.buttons["SaveLoginPrompt.saveLoginButton"].tap()
    }

    private func openLoginsSettings() {
        navigator.goto(SettingsScreen)
        navigator.goto(LoginsSettings)
        waitForExistence(app.tables["Login List"])
    }
    
    func testLoginsListFromBrowserTabMenu() {
        waitForTabsButton()
        //Make sure you can access empty Login List from Browser Tab Menu
        navigator.goto(LoginsSettings)
        waitForExistence(app.tables["Login List"])
        XCTAssertTrue(app.searchFields["Filter"].exists)
        XCTAssertEqual(app.tables["Login List"].cells.count, defaultNumRowsLoginsList)
        saveLogin(givenUrl: testLoginPage)
        //Make sure you can access populated Login List from Browser Tab Menu
        navigator.goto(LoginsSettings)
        waitForExistence(app.tables["Login List"])
        XCTAssertTrue(app.searchFields["Filter"].exists)
        XCTAssertTrue(app.staticTexts[domain].exists)
        XCTAssertTrue(app.staticTexts[domainLogin].exists)
        XCTAssertEqual(app.tables["Login List"].cells.count, defaultNumRowsLoginsList + 1)
    }
    
    func testPasscodeLoginsListFromBrowserTabMenu() {
        navigator.performAction(Action.SetPasscode)
        navigator.nowAt(PasscodeSettings)
        navigator.goto(HomePanelsScreen)
        waitForTabsButton()
        //Make sure you can access empty Login List from Browser Tab Menu
        navigator.goto(LockedLoginsSettings)
        navigator.performAction(Action.UnlockLoginsSettings)
        waitForExistence(app.tables["Login List"])
        XCTAssertTrue(app.searchFields["Filter"].exists)
        XCTAssertEqual(app.tables["Login List"].cells.count, defaultNumRowsLoginsList)
        saveLogin(givenUrl: testLoginPage)
        //Make sure you can access populated Login List from Browser Tab Menu
        navigator.goto(LockedLoginsSettings)
        navigator.performAction(Action.UnlockLoginsSettings)
        waitForExistence(app.tables["Login List"])
        XCTAssertTrue(app.searchFields["Filter"].exists)
        XCTAssertTrue(app.staticTexts[domain].exists)
        XCTAssertTrue(app.staticTexts[domainLogin].exists)
        XCTAssertEqual(app.tables["Login List"].cells.count, defaultNumRowsLoginsList + 1)
    }

    func testSaveLogin() {
        // Initially the login list should be empty
        openLoginsSettings()
        XCTAssertEqual(app.tables["Login List"].cells.count, defaultNumRowsLoginsList)
        // Save a login and check that it appears on the list
        saveLogin(givenUrl: testLoginPage)
        openLoginsSettings()
        waitForExistence(app.tables["Login List"])
        XCTAssertTrue(app.staticTexts[domain].exists)
        XCTAssertTrue(app.staticTexts[domainLogin].exists)
        XCTAssertEqual(app.tables["Login List"].cells.count, defaultNumRowsLoginsList + 1)
        //Check to see how it works with multiple entries in the list- in this case, two for now
        saveLogin(givenUrl: testSecondLoginPage)
        openLoginsSettings()
        waitForExistence(app.tables["Login List"])
        XCTAssertTrue(app.staticTexts[domain].exists)
        XCTAssertTrue(app.staticTexts[domainSecondLogin].exists)
        XCTAssertEqual(app.tables["Login List"].cells.count, defaultNumRowsLoginsList + 2)
    }

    func testDoNotSaveLogin() {
        navigator.openURL(testLoginPage)
        waitUntilPageLoad()
        app.buttons["submit"].tap()
        app.buttons["SaveLoginPrompt.dontSaveButton"].tap()
        // There should not be any login saved
        openLoginsSettings()
        XCTAssertFalse(app.staticTexts[domain].exists)
        XCTAssertFalse(app.staticTexts[domainLogin].exists)
        XCTAssertEqual(app.tables["Login List"].cells.count, defaultNumRowsLoginsList)
    }

    // Smoketest
    func testSavedLoginSelectUnselect() {
        saveLogin(givenUrl: testLoginPage)
        navigator.goto(SettingsScreen)
        openLoginsSettings()
        XCTAssertTrue(app.staticTexts[domain].exists)
        XCTAssertTrue(app.staticTexts[domainLogin].exists)
        app.buttons["Edit"].tap()
        // Due to Bug 1533475 this isn't working
        //XCTAssertTrue(app.cells.images["loginUnselected"].exists)
        XCTAssertTrue(app.buttons["Select All"].exists)
        XCTAssertTrue(app.staticTexts[domain].exists)
        XCTAssertTrue(app.staticTexts[domainLogin].exists)

        app.staticTexts[domain].tap()
        waitForExistence(app.buttons["Deselect All"])
        // Due to Bug 1533475 this isn't working
        //XCTAssertTrue(app.cells.images["loginSelected"].exists)
        XCTAssertTrue(app.buttons["Deselect All"].exists)
        XCTAssertTrue(app.buttons["Delete"].exists)

        app.buttons["Cancel"].tap()
        app.buttons["Edit"].tap()
        // Due to Bug 1533475 this isn't working
        //XCTAssertTrue(app.cells.images["loginUnselected"].exists)
    }

    func testDeleteLogin() {
        saveLogin(givenUrl: testLoginPage)
        openLoginsSettings()
        app.staticTexts[domain].tap()
        app.cells.staticTexts["Delete"].tap()
        waitForExistence(app.alerts["Are you sure?"])
        app.alerts.buttons["Delete"].tap()
        waitForExistence(app.tables["Login List"])
        XCTAssertFalse(app.staticTexts[domain].exists)
        XCTAssertFalse(app.staticTexts[domainLogin].exists)
        XCTAssertEqual(app.tables["Login List"].cells.count, defaultNumRowsLoginsList)
       // Due to Bug 1533475 this isn't working
        //XCTAssertTrue(app.tables["No logins found"].exists)
    }

    func testEditOneLoginEntry() {
        saveLogin(givenUrl: testLoginPage)
        openLoginsSettings()
        XCTAssertTrue(app.staticTexts[domain].exists)
        XCTAssertTrue(app.staticTexts[domainLogin].exists)
        app.staticTexts[domain].tap()
        waitForExistence(app.tables["Login Detail List"])
        XCTAssertTrue(app.tables.cells[loginsListURLLabel].exists)
        XCTAssertTrue(app.tables.cells[loginsListUsernameLabel].exists)
        XCTAssertTrue(app.tables.cells[loginsListPasswordLabel].exists)
        XCTAssertTrue(app.tables.cells.staticTexts["Delete"].exists)
    }

    func testSearchLogin() {
        saveLogin(givenUrl: testLoginPage)
        openLoginsSettings()
        // Enter on Search mode
        app.searchFields["Filter"].tap()
        // Type Text that matches user, website
        app.searchFields["Filter"].typeText("test")
        XCTAssertEqual(app.tables["Login List"].cells.count, defaultNumRowsLoginsList + 1)

        // Type Text that does not match
        app.typeText("b")
        XCTAssertEqual(app.tables["Login List"].cells.count, defaultNumRowsEmptyFilterList)
        //waitForExistence(app.tables["No logins found"])

        // Clear Text
        app.buttons["Clear text"].tap()
        XCTAssertEqual(app.tables["Login List"].cells.count, defaultNumRowsLoginsList + 1)
    }

    // Smoketest
    // Disabling this test until a local website can be used to prevent from false failures
    func testSavedLoginAutofilled() {
        navigator.openURL(urlLogin)
        waitUntilPageLoad()
        //app.webViews.links["Sign in"].tap()
        waitForExistence(app.webViews.textFields["Email"])
        app.webViews.textFields["Email"].tap()
        app.webViews.textFields["Email"].typeText(mailLogin)

        app.webViews.secureTextFields["Password"].tap()
        app.webViews.secureTextFields["Password"].typeText("test15mz")

        app.webViews.buttons["Sign in"].tap()
        app.buttons["SaveLoginPrompt.saveLoginButton"].tap()
        //saveLogin(givenUrl: urlLogin)
        // Clear Data and go to linkedin, fields should be filled in
        navigator.goto(SettingsScreen)
        navigator.performAction(Action.AcceptClearPrivateData)
        navigator.goto(HomePanelsScreen)
        navigator.openNewURL(urlString: urlLogin)
        waitUntilPageLoad()
        waitForExistence(app.webViews.textFields["Email"], timeout: 3)
        let emailValue = app.webViews.textFields["Email"].value!
        XCTAssertEqual(emailValue as! String, mailLogin)
        let passwordValue = app.webViews.secureTextFields["Password"].value!
        XCTAssertEqual(passwordValue as! String, "••••••••")
    }
}
