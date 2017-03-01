//
//  PitchViewController.swift
//  Air Pitch
//
//  Created by Dane Thomas on 2/4/17.
//  Copyright © 2017 Dane Thomas. All rights reserved.
//

import UIKit
import AVFoundation
import ChameleonFramework
import Pulsator
import TwicketSegmentedControl

/*TODO: adjust navBar title
        consider a highlight visual change for buttons
        record a new B natural
        make an info view controller
        change/delete all print statements
        app icons*/

class PitchViewController: UIViewController, AVAudioPlayerDelegate, TwicketSegmentedControlDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var spiralButtonsView: SpiralButtonsView!

    @IBOutlet weak var blowOrTapControl: TwicketSegmentedControl!
    
    var audioSession: AVAudioSession!
    var recorder: AVAudioRecorder!
    var timer = Timer()
    let soundArray = ["CLow", "DFlat", "DNatural", "EFlat", "ENatural", "FNatural", "GFlat", "GNatural", "AFlat", "ANatural", "BFlat", "BNatural", "CHigh"]
    let titleArray = ["C Low", "C#/Db", "D", "D#/Eb", "E", "F", "F#/Gb", "G", "G#/Ab", "A", "A#/Bb", "B", "C High"]
    let hintArray = ["Low C", "C Sharp or D Flat", "D", "D Sharp or E Flat", "E", "F", "F Sharp or G Flat", "G",
                     "G Sharp or A Flat", "A", "A Sharp or B Flat", "B", "High C"]
    var currentButton: PlayerButton?
    var playMode = PlayMode.blow
    
    
    enum PlayMode {
        case tap
        case blow
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setStatusBarStyle(.lightContent)
        view.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: view.frame, andColors: [UIColor.flatRedDark, UIColor.flatSand])
        
        navBar.barTintColor = .flatBlackDark
        navBar.titleTextAttributes = [NSFontAttributeName: blowOrTapControl.font, NSForegroundColorAttributeName: UIColor.flatWhite]

        blowOrTapControl.setSegmentItems(["Blow", "Tap"])
        blowOrTapControl.sliderBackgroundColor = .flatBlackDark
        blowOrTapControl.defaultTextColor = .flatBlackDark
        blowOrTapControl.backgroundColor = .clear
        blowOrTapControl.delegate = self

        
        
        // create buttons in a spiral
        createSoundButtons()
        
        
        // set up the audio session
        audioSession = AVAudioSession.sharedInstance()
        
        audioSession.requestRecordPermission { (allowed) in
            if allowed {
                //TODO: Change this to show an alert to allow recording in settings
                print("recording allowed")
            }
        }
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            //try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.overrideOutputAudioPort(.speaker)
            try audioSession.setPreferredSampleRate(441000)
            try audioSession.setPreferredIOBufferDuration(0.006)
            try audioSession.setActive(true)
        }
        catch {
            print("could not activate session")
            print(error.localizedDescription)
        }
        
        // This file saves the recording, which does not get used again. It is necessary to create an AVAudioRecorder
        let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsDirectory.appendingPathComponent("micRecording.m4a")
        
        let microphoneRecordingSettings: [String : Any] = [AVFormatIDKey: kAudioFormatMPEG4AAC,
                                                           AVSampleRateKey: 8000.0,
                                                           AVNumberOfChannelsKey: 1,
                                                           AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue]
        
        do {
            try recorder = AVAudioRecorder(url: filePath, settings: microphoneRecordingSettings)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.microphoneRecorder = recorder
        }
        catch {
            print("could not initialize recorder.")
        }
        
        recorder.prepareToRecord()
        recorder.isMeteringEnabled = true
        
        
    }
    
    //MARK: Actions
    
    func playPitchFile(_ sender: PlayerButton) {

        
        if playMode == .tap {
            playInTapMode(button: sender)
        }
        else {
            playInBlowMode(button: sender)
        }
    }
    
    func playInTapMode(button: PlayerButton) {
        
        currentButton?.soundPlayer?.stop()
        currentButton?.isSelected = false
        currentButton?.pulsator.stop()
        
        // When the user selects button that is currently playing, sound stops and button is de-selected
        if currentButton === button {
            currentButton = nil
            return
        }
        
        button.pulsator.start()
        button.soundPlayer?.currentTime = 0.0
        button.soundPlayer?.volume = 1.0
        button.soundPlayer?.play()
        button.isSelected = true
        currentButton = button
    }
    
    func playInBlowMode(button: PlayerButton) {
        
        
        if timer.isValid {
            timer.invalidate()
            recorder.stop()
            currentButton?.soundPlayer?.stop()
            currentButton?.isSelected = false
            currentButton?.pulsator.stop()
        }
        
        if currentButton === button {
            currentButton = nil
            return
        }
        
        button.isSelected = true
        button.soundPlayer?.prepareToPlay()
        button.pulsator.start()
        recorder.record()
        timer = Timer.scheduledTimer(timeInterval: 0.075, target: self, selector: #selector(PitchViewController.updateMicInput), userInfo: nil, repeats: true)
        currentButton = button
   
    }
    
    func updateMicInput() {
        
        recorder.updateMeters()
        
        let power = recorder.averagePower(forChannel: 0)
        //TODO: Change this later once the blowing sounds natural
        // every change in 1 decible between -13 and -3 changes volume by 1/15th
        let decibleConversion = power + 3  // adding 3 to power makes -3 decibels equal to 0 change to volume
        let volumeAdjustment = Float(decibleConversion / 10)
        
        let volume = volumeAdjustment <= 0 ? (1 + volumeAdjustment) : 1.0
        
        if power >= -13 {
            
            print("sound is happening at \(power)")
            // fade duration matches length of timer before repeating
            currentButton?.soundPlayer?.setVolume(volume, fadeDuration: 0.075)
            print(currentButton?.soundPlayer?.volume.debugDescription ?? "no volume")
            currentButton?.soundPlayer?.play()
            
        }
        else {
            currentButton?.soundPlayer?.setVolume(0.0, fadeDuration: 0.3)
            currentButton?.soundPlayer?.pause()
            currentButton?.soundPlayer?.currentTime = 0.0
        }
    }
    
    //MARK: AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        currentButton?.isSelected = false
        
        print("sound finished")
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print(error.debugDescription)
    }
    
    //MARK: Private Methods
    

    private func createSoundButtons() {
        
        for button in spiralButtonsView.buttons {
            
            let index = button.tag - 1
            
            button.setTitle(titleArray[index], for: [])
            button.titleLabel?.font = blowOrTapControl.font
            
            // Accessibility
            button.accessibilityHint = "Plays a \(hintArray[index])"
            button.accessibilityLabel = hintArray[index]
            
            let soundName = soundArray[index]
            guard let filePath = Bundle.main.path(forResource: "\(soundName)", ofType: "m4a", inDirectory: "Audio Files") else {
                print("Could not find audio file")
                return
            }
            let url = URL(fileURLWithPath: filePath)
            
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.delegate = self
                button.soundPlayer = player
            }
            catch {
                print("Could not create player for \(soundName)")
            }
            
            button.addTarget(self, action: #selector(PitchViewController.playPitchFile(_:)), for: .touchUpInside)
            
        }
    }
    
    //MARK: Twicket Segmented Control Delegate
    
    /*@IBAction func tapOrBlow(_ sender: TwicketSegmentedControl) {

        timer.invalidate()
        recorder.stop()
        currentButton?.soundPlayer?.stop()
        currentButton?.isSelected = false
        currentButton = nil
        
        playMode = sender.selectedSegmentIndex == 0 ? PlayMode.blow : PlayMode.tap
    
    }*/
    
    func didSelect(_ segmentIndex: Int) {
        timer.invalidate()
        recorder.stop()
        currentButton?.soundPlayer?.stop()
        currentButton?.isSelected = false
        currentButton = nil
        
        playMode = segmentIndex == 0 ? PlayMode.blow : PlayMode.tap
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        recorder.deleteRecording()
    }


}

