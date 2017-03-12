//
//  SpiralButtonsView.swift
//  Air Pitch
//
//  Created by Dane Thomas on 2/22/17.
//  Copyright © 2017 Dane Thomas. All rights reserved.
//

import UIKit

@IBDesignable class SpiralButtonsView: UIView {
    
    //MARK: Properties
    var buttons = [PlayerButton]()
    
    @IBInspectable var numOfButtons: Int = 13 {
        didSet {
            createButtons()
            layoutSubviews()
        }
    }
    
    @IBInspectable var buttonSize: CGSize = CGSize(width: 52, height: 52) {
        didSet {
            createButtons()
            layoutSubviews()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
        createButtons()
    }
    
   required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
        createButtons()
    }
    
   override func layoutSubviews() {
        super.layoutSubviews()
        var radius = self.bounds.width / 3 < self.bounds.height / 4 ? self.bounds.width / 3 : self.bounds.height / 4
        let radiusInc = radius / (buttonSize.width / 2)
        // This makes the first button be the topmost button
        var angle = 270.0  * (M_PI / 180)
        // must be in radians because the Darwin trig functions use radians
        let angleInc = (360.0 / 12.0) * (M_PI / 180)
        let circleCenter = CGPoint(x: self.center.x + (buttonSize.width / 4), y: (buttonSize.height) + (radius + (radiusInc * (CGFloat(numOfButtons) - 1))))
        for button in buttons {
            let x = circleCenter.x + CGFloat(cos(angle)) * radius
            let y = circleCenter.y + CGFloat(sin(angle)) * radius
            button.center = CGPoint(x: x, y: y)
            angle += angleInc
            radius += radiusInc
        }
    }
    
    //MARK: - Methods
    
    private func setUpView() {
        backgroundColor = UIColor.clear
    }

    private func createButtons() {
        // remove current buttons
        for button in buttons {
            willRemoveSubview(button)
            button.removeFromSuperview()
        }
        buttons.removeAll()
        let bundle = Bundle(for: SpiralButtonsView.self)
        let buttonImage = UIImage(named: "button", in: bundle, compatibleWith: self.traitCollection)
        for index in 0..<numOfButtons {
            let button = PlayerButton()
            button.tag = index + 1 // button tags start at 1
            button.setTitleColor(.flatWhite, for: [])
            button.frame.size = buttonSize
            button.setTitle("test\(button.tag)", for: [])
            button.titleLabel?.textAlignment = .center
            button.setBackgroundImage(buttonImage, for: [])
            button.layer.masksToBounds = false
            button.layer.shadowColor = UIColor.darkGray.cgColor
            button.layer.shadowOpacity = 1.0
            button.layer.shadowOffset = CGSize(width: 0, height: 0.3)
            buttons.append(button)
            self.addSubview(button)
        }
    }
}
