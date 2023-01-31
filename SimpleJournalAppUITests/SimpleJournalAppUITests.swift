//
//  SimpleJournalAppUITests.swift
//  SimpleJournalAppUITests
//
//  Created by Tomasz Kubiak on 11/12/22.
//

import XCTest

class SimpleJournalAppUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }


    func testAddingNewEntry() throws {
        
        app.tables.cells.containing(.staticText, identifier:"Journal")/*@START_MENU_TOKEN@*/.staticTexts["Answer"]/*[[".buttons[\"Answer\"].staticTexts[\"Answer\"]",".staticTexts[\"Answer\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        
        let scrollViewsQuery = app.scrollViews
        
        let summaryOfTheDayElement = scrollViewsQuery.otherElements.containing(.staticText, identifier:"Summary of the day").element
        let summaryTextView = summaryOfTheDayElement.children(matching: .textView).firstMatch
        summaryTextView.tap()
        summaryTextView.typeText("This is a summary of the day")
        summaryOfTheDayElement.swipeLeft()
        
        let textView = scrollViewsQuery.otherElements.containing(.staticText, identifier:"What did i do good?").children(matching: .textView).element
        textView.tap()
        textView.typeText("This is what i did good")
//        textView.swipeLeft()
        
        
        
        
        
        textView.swipeDown(velocity: .fast)
        
        
        let tabBar = XCUIApplication().tabBars["Tab Bar"]
        
        tabBar.buttons["chart column"].tap()
        
        XCTAssertTrue(app.tables.cells.staticTexts["31.01.2023"].exists)
        
        
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
