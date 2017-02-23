//
//  BackgroundView.swift
//  Air Pitch
//
//  Created by Dane Thomas on 2/21/17.
//  Copyright © 2017 Dane Thomas. All rights reserved.
//

import UIKit

class BackgroundView: UIView {

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
    }
    
    func setUpView() {
        
        // sets up a gradient from red to gold
        //TODO: try gold radiating from center
        let backgroundColor = UIColor(red: 0.83, green: 0.2, blue: 0.16, alpha: 0.95)
        let overColor = UIColor(red: 0.75, green: 0.63, blue: 0.49, alpha: 0.95)
        
        let gradient = CAGradientLayer()
        gradient.colors = [backgroundColor.cgColor, overColor.cgColor]
        gradient.frame = self.bounds
        gradient.locations = [0.5]
        gradient.zPosition = -1
        self.layer.addSublayer(gradient)
    }

}
