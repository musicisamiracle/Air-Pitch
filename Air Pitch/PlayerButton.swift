//
//  PlayerButton.swift
//  Air Pitch
//
//  Created by Dane Thomas on 2/7/17.
//  Copyright © 2017 Dane Thomas. All rights reserved.
//

/*TODO: make it conform to NSCoder*/
import UIKit
import AVFoundation
import Pulsator

class PlayerButton: UIButton {
    
    var soundPlayer: AVAudioPlayer?
    var pulsator = Pulsator()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addPulseLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addPulseLayer()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        pulsator.position = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        pulsator.radius = (bounds.width / 3) * 2
    }
    
    private func addPulseLayer() {
        pulsator.backgroundColor = UIColor.flatWhiteDark.cgColor
        pulsator.numPulse = 5
        layer.addSublayer(pulsator)
    }
}
