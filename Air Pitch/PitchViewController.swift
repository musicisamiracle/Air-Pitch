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

class PitchViewController: UIViewController, AVAudioPlayerDelegate, AVAudioSessionDelegate, TwicketSegmentedControlDelegate {
    
    //MARK: - Properties
    @IBOutlet weak var stackViewContainer: UIView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var spiralButtonsView: SpiralButtonsView!
    @IBOutlet weak var blowOrTapControl: TwicketSegmentedControl!
    @IBOutlet weak var infoOverlay: UIView!
    
    private var audioSession: AVAudioSession!
    private var recorder: AVAudioRecorder?
    private var timer = Timer()
    private var currentButton: PlayerButton?
    private var playMode = PlayMode.blow
    private var alerts: [UIAlertController] = []
    
    enum PlayMode {
        case tap
        case blow
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		audioSession = AVAudioSession.sharedInstance()
		do {
			try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
			try audioSession.setPreferredSampleRate(441000)
			try audioSession.setPreferredIOBufferDuration(0.006)
		}
		catch {
			// If the audio session does not get initialized, an alert shows after view appears.
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
		}
		catch {
			let alert = UIAlertController(title: "Microphone failure", message: "Using the blow function of the app will not work due to an unknown problem.", preferredStyle: .alert)
			alerts.append(alert)
		}
		
        finishSettingUpView()
        createSoundButtons()
		NotificationCenter.default.addObserver(self, selector: #selector(PitchViewController.willResignActive), name: .UIApplicationWillResignActive, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(PitchViewController.didBecomeActive), name: .UIApplicationDidBecomeActive, object: nil)
    }
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	@objc private func willResignActive() {
		stopCurrentButton()
		currentButton = nil
		// The recorder file is not needed, so it can be deleted everytime the app goes inactive.
		recorder?.deleteRecording()
		do {
			try audioSession?.setActive(false)
		}
		catch {
			print("audio session not deactivated")
		}
	}
	
	@objc private func didBecomeActive() {
		do {
			try audioSession.setActive(true)
		}
		catch {
			let alert = UIAlertController(title: "Audio Session Failure", message: "An audio session could not be initalized. Please terminate the app and try to open again.", preferredStyle: .alert)
			alerts.append(alert)
		}
		
		recorder?.prepareToRecord()
		recorder?.isMeteringEnabled = true
	}
	
    override func viewDidAppear(_ animated: Bool) {
		
        audioSession?.requestRecordPermission({ [unowned self] (allowed) in
            if !allowed {
                let alert = self.createMicrophoneAlert()
                self.alerts.append(alert)
            }
        })
        
        if !alerts.isEmpty {
            showAlerts()
        }
        
    }
    
    private func createMicrophoneAlert() -> UIAlertController {
        let microphoneAlert = UIAlertController(title: "Microphone Access", message: "In order to use the blow function of Air Pitch, go to Settings > Privacy > Microphone and allow Air Pitch to use the microphone.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: { action in
            // Go to tap mode
            self.blowOrTapControl.move(to: 1)
            self.didSelect(1)
        })
        microphoneAlert.addAction(action)
        return microphoneAlert
    }
    
    private func showAlerts() {
        guard !alerts.isEmpty else {
            return
        }
        let alert = alerts[0]
        if alert.title != "Microphone Access" {
            let action = UIAlertAction(title: "OK", style: .default, handler: { action in
                self.alerts.remove(at: 0)
                self.showAlerts()
            })
            alert.addAction(action)
        }
        present(alert, animated: true, completion: nil)
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
    
    private func playInTapMode(button: PlayerButton) {
        stopCurrentButton()
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
    
    private func playInBlowMode(button: PlayerButton) {
        if timer.isValid {
            timer.invalidate()
            recorder?.stop()
            stopCurrentButton()
        }
        if currentButton === button {
            currentButton = nil
            return
        }
        button.isSelected = true
        button.soundPlayer?.prepareToPlay()
        button.pulsator.start()
        recorder?.record()
        timer = Timer.scheduledTimer(timeInterval: 0.075, target: self, selector: #selector(PitchViewController.updateMicInput), userInfo: nil, repeats: true)
        currentButton = button
    }
    
    func stopCurrentButton() {
        currentButton?.soundPlayer?.stop()
        currentButton?.pulsator.stop()
        currentButton?.isSelected = false
		recorder?.stop()
    }
    
    func updateMicInput() {
        guard let recorder = recorder else {
            timer.invalidate()
            stopCurrentButton()
            let alert = UIAlertController(title: "Microphone Error", message: "Air Pitch cannot access the microphone for an unknown reason", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return
        }
        recorder.updateMeters()
        let power = recorder.averagePower(forChannel: 0)
        // every change in 1 decible between -10 and -0 changes volume by 0.1
        let volumeAdjustment = Float(power / 10)
        let volume = volumeAdjustment <= 0 ? (1 + volumeAdjustment) : 1.0
        if power >= -10 {
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
        stopCurrentButton()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        stopCurrentButton()
        let alert = UIAlertController(title: "Decode Error", message: "There was an error decoding the audio file\n\(error?.localizedDescription)", preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - View Setup
    
    private func finishSettingUpView() {
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
        blowOrTapControl.accessibilityLabel = "blowOrTap"
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
            if let filePath = Bundle.main.path(forResource: "\(soundName)", ofType: "m4a", inDirectory: "Audio Files") {
                let url = URL(fileURLWithPath: filePath)
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.delegate = self
                    button.soundPlayer = player
                }
                catch {
                    let alert = UIAlertController(title: "Audio File Error", message: "Unable to prepare \(soundName) to play", preferredStyle: .alert)
                    alerts.append(alert)
                }
                button.addTarget(self, action: #selector(PitchViewController.playPitchFile(_:)), for: .touchUpInside)
            }
            else {
                let alert = UIAlertController(title: "Audio File Not Found", message: "Unable to locate \(soundName)", preferredStyle: .alert)
                alerts.append(alert)
            }
        }
    }

    //MARK: - Twicket Segmented Control Delegate
    func didSelect(_ segmentIndex: Int) {
        if segmentIndex == 0 {
            if audioSession?.recordPermission() == .denied {
                let microphoneAlert = createMicrophoneAlert()
                present(microphoneAlert, animated: true, completion: nil)
            }
        }
        timer.invalidate()
        stopCurrentButton()
        currentButton = nil
        playMode = segmentIndex == 0 ? PlayMode.blow : PlayMode.tap
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        recorder?.deleteRecording()
    }
	
	//MARK: - AVAudioSessionDelegate
	func beginInterruption() {
		stopCurrentButton()
		currentButton = nil
	}
}

