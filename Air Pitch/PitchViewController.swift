//
//  PitchViewController.swift
//  Air Pitch
//
//  Created by Dane Thomas on 2/4/17.
//  Copyright © 2017 Dane Thomas. All rights reserved.
//

import UIKit
import AVFoundation


/*TODO:
        Implement microphone
        Design the layout*/

class PitchViewController: UIViewController, AVAudioPlayerDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var pitchViewContainer: UIView!
    let soundArray = ["ENaturalLow", "FNatural", "FSharp", "GNatural", "AFlat", "ANatural", "BFlat", "BNatural", "CNatural", "CSharp", "DNatural", "EFlat", "ENaturalHigh"]
    var playerArray = [AVAudioPlayer]()
    var soundIsPlaying = false
    var currentPlayer: AVAudioPlayer?
    var currentButtonTag: Int?
    
    //MARK: Actions
    
    func playPitchFile(_ sender: UITapGestureRecognizer) {
        
        // The index of the player array corresponds to the tag of the view that was tapped.
        let playerIndex = sender.view!.tag - 1
        print("tapped \(soundArray[playerIndex])")
        currentButtonTag = sender.view!.tag
        
        /* left off here. Use guard let so you can change isSelected later
         
         
         
         
         
         */
        if let senderButton = sender.view as? UIButton {
            senderButton.isSelected = true
        }
        let player = playerArray[playerIndex]
        
        // The start time should be adjusted according to a natural starting point in the sound file.
        player.currentTime = 0.25
        
        if soundIsPlaying {
            if currentPlayer !== player {
                currentPlayer?.stop()
                player.play()
                soundIsPlaying = true
                currentPlayer = player
            }
            else {
                currentPlayer?.stop()
                currentPlayer?.currentTime = 0.25
                soundIsPlaying = false
            }
        }
        else {
            player.play()
            soundIsPlaying = true
            currentPlayer = player
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createSoundPlayers()
        
        for button in pitchViewContainer.subviews {
            
            if let button = button as? UIButton {
                button.setBackgroundImage(UIImage(named: "selected") , for: .selected)
            }
            let gesture = UITapGestureRecognizer(target: self, action: #selector(PitchViewController.playPitchFile(_:)))
            button.addGestureRecognizer(gesture)
        }
    }
    
    //MARK: AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("sound finished")
        

    }
    
    //MARK: Private Methods
    
    private func createSoundPlayers() {
        for sound in soundArray {
            guard let filePath = Bundle.main.path(forResource: "\(sound)", ofType: "mp3", inDirectory: "Pitches") else {
                print("Could not find audio file")
                return
            }
            let url = URL(fileURLWithPath: filePath)
            
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.delegate = self
                playerArray.append(player)
            }
            catch {
                print("Could not create player for \(sound)")
            }
            
            
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

