//
//  Air_PitchTests.swift
//  Air PitchTests
//
//  Created by Dane Thomas on 2/4/17.
//  Copyright © 2017 Dane Thomas. All rights reserved.
//

import XCTest
@testable import Air_Pitch

class Air_PitchTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSetUpButton() {
        let button = PlayerButton()
        
        XCTAssertEqual(button.backgroundImage(for: []), UIImage(named: "button"))
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
