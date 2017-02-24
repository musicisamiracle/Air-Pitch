//
//  Air_PitchUITests.swift
//  Air PitchUITests
//
//  Created by Dane Thomas on 2/4/17.
//  Copyright © 2017 Dane Thomas. All rights reserved.
//

import XCTest
@testable import Air_Pitch

class Air_PitchUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testTapOrBlow() {
        let blowButton = app.buttons["Blow"]
        let tapButton = app.buttons["Tap"]
        XCTAssertNotNil(blowButton, "could not locate segmented control")

        //TODO: Not sure what to do with these
        
        
    }
}
