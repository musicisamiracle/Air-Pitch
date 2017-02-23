//
//  PitchViewController.swift
//  Air Pitch
//
//  Created by Dane Thomas on 2/4/17.
//  Copyright © 2017 Dane Thomas. All rights reserved.
//

import UIKit
import AVFoundation


/*TODO: make a new view and make it Gradient view instead of using the root view
        delete created recording file when app resigns active
        Design the layout
        button icon
        app icons*/

class PitchViewController: UIViewController, AVAudioPlayerDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var spiralButtonsView: SpiralButtonsView!
    @IBOutlet weak var blowOrTapControl: UISegmentedControl!
    @IBOutlet weak var background: BackgroundView!
    var audioSession: AVAudioSession!
    var recorder: AVAudioRecorder!
    var timer = Timer()
    
    let soundArray = ["CLow", "DFlat", "DNatural", "EFlat", "ENatural", "FNatural", "GFlat", "GNatural", "AFlat", "ANatural", "BFlat", "BNatural", "CHigh"]
    let titleArray = ["C Low", "C#/Db", "D", "D#/Eb", "E", "F", "F#/Gb", "G", "G#/Ab", "A", "A#/Bb", "B", "C High"]
    var currentButton: PlayerButton?
    var playMode = PlayMode.blow
    
    
    enum PlayMode {
        case tap
        case blow
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
        
        currentButton?.soundPlayer.stop()
        currentButton?.isSelected = false
        
        // When the user selects button that is currently playing, sound stops and button is de-selected
        if currentButton === button {
            currentButton = nil
            return
        }
        
        button.soundPlayer.currentTime = 0.0
        button.soundPlayer.volume = 1.0
        button.soundPlayer.play()
        button.isSelected = true
        currentButton = button
    }
    
    func playInBlowMode(button: PlayerButton) {
        
        
        if timer.isValid {
            timer.invalidate()
            recorder.stop()
            currentButton?.soundPlayer.stop()
            currentButton?.isSelected = false
        }
        
        if currentButton === button {
            currentButton = nil
            return
        }
        
        button.isSelected = true
        button.soundPlayer.prepareToPlay()
        recorder.record()
        timer = Timer.scheduledTimer(timeInterval: 0.075, target: self, selector: #selector(PitchViewController.updateMicInput), userInfo: nil, repeats: true)
        currentButton = button
   
    }
    
    func updateMicInput() {
        
        recorder.updateMeters()
        
        /*print("gain: \(audioSession.inputGain)")
         print("sample rate: \(audioSession.sampleRate)")
         print("buffer: \(audioSession.ioBufferDuration)")
         print("latency: \(audioSession.inputLatency)")
         print("input channels: \(audioSession.inputNumberOfChannels)")*/
        
        let power = recorder.averagePower(forChannel: 0)
        //TODO: Change this later once the blowing sounds natural
        // every change in 1 decible between -13 and -3 changes volume by 1/15th
        let decibleConversion = power + 3  // adding 3 to power makes -3 decibels equal to 0 change to volume
        let volumeAdjustment = Float(decibleConversion / 10)
        
        let volume = volumeAdjustment <= 0 ? (1 + volumeAdjustment) : 1.0
        
        if power >= -13 {
            
            print("sound is happening at \(power)")
            // fade duration matches length of timer before repeating
            currentButton?.soundPlayer.setVolume(volume, fadeDuration: 0.075)
            print(currentButton?.soundPlayer.volume.debugDescription ?? "no volume")
            currentButton?.soundPlayer.play()
            
        }
        else {
            currentButton?.soundPlayer.setVolume(0.0, fadeDuration: 0.3)
            currentButton?.soundPlayer.pause()
            currentButton?.soundPlayer.currentTime = 0.0
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create buttons in a spiral
        createSoundButtons()

        
        // set up the audio session
        audioSession = AVAudioSession.sharedInstance()
        
        audioSession.requestRecordPermission { (allowed) in
            if allowed {
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
        let filePath = documentsDirectory.appendingPathComponent("testRecording.m4a")
        
        let microphoneRecordingSettings: [String : Any] = [AVFormatIDKey: kAudioFormatMPEG4AAC,
                                                           AVSampleRateKey: 8000.0,
                                                           AVNumberOfChannelsKey: 1,
                                                           AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue]
        
        do {
            try recorder = AVAudioRecorder(url: filePath, settings: microphoneRecordingSettings)
        }
        catch {
            print("could not initialize recorder.")
        }
        
        recorder.prepareToRecord()
        recorder.isMeteringEnabled = true
        

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
    
    //MARK: Segmented Control
    
    @IBAction func tapOrBlow(_ sender: UISegmentedControl) {

        timer.invalidate()
        recorder.stop()
        currentButton?.soundPlayer.stop()
        currentButton?.isSelected = false
        currentButton = nil
        
        playMode = sender.selectedSegmentIndex == 0 ? PlayMode.blow : PlayMode.tap
    
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

