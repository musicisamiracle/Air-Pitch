//
//  PlayerButton.swift
//  Air Pitch
//
//  Created by Dane Thomas on 2/7/17.
//  Copyright © 2017 Dane Thomas. All rights reserved.
//

/*TODO: put background image in here
        make it conform to NSCoder*/
import UIKit
import AVFoundation

class PlayerButton: UIButton {
    
    var soundPlayer: AVAudioPlayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpButton()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func setUpButton() {
        let bundle = Bundle(for: SpiralButtonsView.self)
        let buttonImage = UIImage(named: "button", in: bundle, compatibleWith: self.traitCollection)
        
        setBackgroundImage(buttonImage, for: [])
    }
    
    

}
