//
//  Air_PitchTests.swift
//  Air PitchTests
//
//  Created by Dane Thomas on 2/4/17.
//  Copyright © 2017 Dane Thomas. All rights reserved.
//

import XCTest
import AVFoundation
@testable import Air_Pitch

class Air_PitchTests: XCTestCase {
    
    var vc: PitchViewController!
    
    override func setUp() {
        super.setUp()
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle(for: PitchViewController.self))
        vc = storyBoard.instantiateInitialViewController() as! PitchViewController
        XCTAssertNotNil(vc.view, "The view was not loaded")
        
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    //MARK: Player Button View
    func testSetUpButton() {
        let button = PlayerButton()
        
        XCTAssertNotNil(button)
        
    }
    
    //MARK: Spiral Button View
    func testCreateButtons() {
        let spiralButtonsView = SpiralButtonsView()
        spiralButtonsView.numOfButtons = 15
        spiralButtonsView.buttonSize = CGSize(width: 50, height: 50)
        
     XCTAssertEqual(spiralButtonsView.buttons.count, 15)
    }
}
