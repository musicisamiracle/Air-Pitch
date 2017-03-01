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
        
        XCTAssertNotNil(button.pulsator)
        
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
    
    //MARK: PitchViewController
    func testPlayInTapMode() {
        let button = vc.spiralButtonsView.buttons[0]
        vc.playInTapMode(button: button)
        
        XCTAssert(vc.currentButton!.soundPlayer!.isPlaying, "Sound did not play")
        vc.currentButton?.soundPlayer?.stop()
    }
    
    func testPlayInBlowMode() {
        let button = vc.spiralButtonsView.buttons[0]
        vc.playInBlowMode(button: button)
        
        XCTAssert(vc.recorder.isRecording, "Recorder is not recording")
        
        XCTAssert(vc.timer.isValid, "Timer did not start")
        vc.timer.invalidate()
        vc.recorder.stop()
    }
    
}
