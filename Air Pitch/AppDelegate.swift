//
//  AppDelegate.swift
//  Air Pitch
//
//  Created by Dane Thomas on 2/4/17.
//  Copyright © 2017 Dane Thomas. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var microphoneRecorder: AVAudioRecorder?
    var audioSession: AVAudioSession!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            try audioSession.setPreferredSampleRate(441000)
            try audioSession.setPreferredIOBufferDuration(0.006)
        }
        catch {
            // If the audio session does not get initialized, an alert shows after PitchViewController is created.
        }
        // This file saves the recording, which does not get used again. It is necessary to create an AVAudioRecorder
        let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsDirectory.appendingPathComponent("micRecording.m4a")
        let microphoneRecordingSettings: [String : Any] = [AVFormatIDKey: kAudioFormatMPEG4AAC,
                                                           AVSampleRateKey: 8000.0,
                                                           AVNumberOfChannelsKey: 1,
                                                           AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue]
        do {
            try microphoneRecorder = AVAudioRecorder(url: filePath, settings: microphoneRecordingSettings)
        }
        catch {
            // If the audio recorder does not get initialized, an alert shows after PitchViewController is created.
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // The recorder file is not needed, so it can be deleted everytime the app goes inactive.
        microphoneRecorder?.deleteRecording()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        microphoneRecorder?.prepareToRecord()
        microphoneRecorder?.isMeteringEnabled = true
    }
}

