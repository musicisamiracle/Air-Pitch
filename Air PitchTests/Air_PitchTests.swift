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

    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    //MARK: Player Button View
    func testSetUpButton() {
        let button = PlayerButton()
        
        XCTAssertEqual(button.backgroundImage(for: []), UIImage(named: "button"))
        
    }

    
  //MARK: Gradient View
    func testGradientViewLayoutSubviews() {
        let gradientView = GradientView()
        gradientView.layoutSubviews()
        
        XCTAssertNotNil((gradientView.layer as? CAGradientLayer)?.colors, "There are not colors for the gradient")
        XCTAssertNotNil((gradientView.layer as? CAGradientLayer)?.locations, "There are no locations for the gradient")
        
    }
    
    //MARK: Spiral Button View
    func testCreateButtons() {
        let spiralButtonsView = SpiralButtonsView()
        
        spiralButtonsView.numOfButtons = 15
        spiralButtonsView.buttonSize = CGSize(width: 50, height: 50)
        
        spiralButtonsView.createButtons()
        
        let testButton = spiralButtonsView.buttons[0]
        
        XCTAssertEqual(spiralButtonsView.buttons.count, 15)
        XCTAssertEqual(testButton.frame.width, 50)
    }
    
    
}
