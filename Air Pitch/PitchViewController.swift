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

/*TODO: deal with audio session
        move some things out of viewDidLoad into functions
        error handling
        record a new B natural
        app icons*/

class PitchViewController: UIViewController, AVAudioPlayerDelegate, TwicketSegmentedControlDelegate {
    
    //MARK: - Properties
    
    @IBOutlet weak var stackViewContainer: UIView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var spiralButtonsView: SpiralButtonsView!
    @IBOutlet weak var blowOrTapControl: TwicketSegmentedControl!
    @IBOutlet weak var infoOverlay: UIView!
    
    var audioSession: AVAudioSession!
    var recorder: AVAudioRecorder!
    private var timer = Timer()
    private var currentButton: PlayerButton?
    private var playMode = PlayMode.blow
    private var microphoneAlert: UIAlertController!
    
    enum PlayMode {
        case tap
        case blow
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        finishSetttingUpView()
        createSoundButtons()
        setUpAudioSession()
        setUpAudioRecorder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        microphoneAlert = UIAlertController(title: "Microphone Access", message: "In order to use the blow function of Air Pitch, go to Settings > Privacy > Microphone and allow Air Pitch to use the microphone.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { [unowned self] action in
            // Go to tap mode
            self.blowOrTapControl.move(to: 1)
            self.blowOrTapControl.delegate?.didSelect(1)
            self.microphoneAlert.dismiss(animated: true, completion: nil)
        })
        microphoneAlert.addAction(action)
        
        audioSession.requestRecordPermission { [unowned self] (allowed) in
            if !allowed {
                self.present(self.microphoneAlert, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: - Actions
    
    @IBAction func infoButton(_ sender: UIButton) {
        infoOverlay.isHidden = false
    }
    
    @IBAction func dismissButton(_ sender: UIButton) {
        infoOverlay.isHidden = true
    }
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
        // every change in 1 decible between -13 and -3 changes volume by 0.1
        let decibleConversion = power + 3  // adding 3 to power makes -3 decibels equal to 0 change to volume
        let volumeAdjustment = Float(decibleConversion / 10)
        
        let volume = volumeAdjustment <= 0 ? (1 + volumeAdjustment) : 1.0
        
        if power >= -13 {
            // Fade duration matches length of timer before repeating
            currentButton?.soundPlayer?.setVolume(volume, fadeDuration: 0.075)
            currentButton?.soundPlayer?.play()
            
        }
        else {
            currentButton?.soundPlayer?.setVolume(0.0, fadeDuration: 0.3)
            currentButton?.soundPlayer?.pause()
            currentButton?.soundPlayer?.currentTime = 0.0
        }
    }
    
    //MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        currentButton?.isSelected = false
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        //TODO: Create an alert
    }
    
    //MARK: - Private Methods
    
    private func finishSetttingUpView() {
        setStatusBarStyle(.lightContent)
        stackViewContainer.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: view.frame, andColors: [UIColor.flatRedDark, UIColor.flatSand])
        
        navBar.barTintColor = .flatBlackDark
        navBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "AirAmericana", size: 25)!, NSForegroundColorAttributeName: UIColor.flatWhite]
        
        blowOrTapControl.setSegmentItems(["Blow", "Tap"])
        blowOrTapControl.sliderBackgroundColor = .flatBlackDark
        blowOrTapControl.defaultTextColor = .flatBlackDark
        blowOrTapControl.font = UIFont(name: "AirAmericana", size: 15)!
        blowOrTapControl.backgroundColor = .clear
        blowOrTapControl.delegate = self
    }
    
    private func createSoundButtons() {
        let soundArray = ["CLow", "DFlat", "DNatural", "EFlat", "ENatural", "FNatural", "GFlat", "GNatural", "AFlat", "ANatural", "BFlat", "BNatural", "CHigh"]
        let titleArray = ["C\nLow", "C#/\nDb", "D", "D#/\nEb", "E", "F", "F#/\nGb", "G", "G#/\nAb", "A", "A#/\nBb", "B", "C\nHigh"]
        let hintArray = ["Low C", "C Sharp or D Flat", "D", "D Sharp or E Flat", "E", "F", "F Sharp or G Flat", "G",
                         "G Sharp or A Flat", "A", "A Sharp or B Flat", "B", "High C"]
        
        for button in spiralButtonsView.buttons {
            let index = button.tag - 1
            
            button.setTitle(titleArray[index], for: [])
            button.titleLabel?.font = UIFont(name: "AmericanTypewriter", size: 15)
            button.titleLabel?.numberOfLines = 0
            
            // Accessibility
            button.accessibilityHint = "Plays a \(hintArray[index])"
            button.accessibilityLabel = hintArray[index]
            
            let soundName = soundArray[index]
            guard let filePath = Bundle.main.path(forResource: "\(soundName)", ofType: "m4a", inDirectory: "Audio Files") else {
                //TODO: error handling
                return
            }
            let url = URL(fileURLWithPath: filePath)
            
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.delegate = self
                button.soundPlayer = player
            }
            catch {
                //TODO: error handling
            }
            
            button.addTarget(self, action: #selector(PitchViewController.playPitchFile(_:)), for: .touchUpInside)
            
        }
    }
    
    private func setUpAudioSession() {
        // set up the audio session
        audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            //try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.overrideOutputAudioPort(.speaker)
            try audioSession.setPreferredSampleRate(441000)
            try audioSession.setPreferredIOBufferDuration(0.006)
            try audioSession.setActive(true)
        }
        catch {
            //TODO: error handling
        }
    }
    
    private func setUpAudioRecorder() {
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
            //TODO: error handling
        }
        
        recorder.prepareToRecord()
        recorder.isMeteringEnabled = true
    }
    
    //MARK: - Twicket Segmented Control Delegate
    
    func didSelect(_ segmentIndex: Int) {
        if segmentIndex == 0 {
            if audioSession.recordPermission() == .denied {
                present(microphoneAlert, animated: true, completion: nil)
            }
        }
        
        timer.invalidate()
        recorder.stop()
        currentButton?.soundPlayer?.stop()
        currentButton?.pulsator.stop()
        currentButton?.isSelected = false
        currentButton = nil
        
        playMode = segmentIndex == 0 ? PlayMode.blow : PlayMode.tap
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        recorder.deleteRecording()
    }
}

