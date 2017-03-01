//
//  GradientView.swift
//  Air Pitch
//
//  Created by Dane Thomas on 2/22/17.
//  Copyright © 2017 Dane Thomas. All rights reserved.
//

import UIKit
//TODO: Not sure I need this anymore
@IBDesignable class GradientView: UIView {
    @IBInspectable var topColor: UIColor = UIColor.white {
        didSet {
            layoutSubviews()
        }
    }
    @IBInspectable var bottomColor: UIColor = UIColor.black {
        didSet {
            layoutSubviews()
        }
    }
    
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        (layer as! CAGradientLayer).colors = [topColor.cgColor, bottomColor.cgColor]
        (layer as! CAGradientLayer).locations = [0.5]
    }
    

}
