//
//  AppDelegate.swift
//  Air Pitch
//
//  Created by Dane Thomas on 2/4/17.
//  Copyright © 2017 Dane Thomas. All rights reserved.
//

import UIKit
import AVFoundation

//TODO: Delete all methods not used
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var microphoneRecorder: AVAudioRecorder?
    var audioSession: AVAudioSession?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession?.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            try audioSession?.setPreferredSampleRate(441000)
            try audioSession?.setPreferredIOBufferDuration(0.006)
        }
        catch {
            // If the audio session does not get initialized, an alert shows after PitchViewController is created.
        }
        // This file saves the recording, which does not get used again. It is necessary to create an AVAudioRecorder
        let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsDirectory.appendingPathComponent("micRecording.m4a")
        
        let microphoneRecordingSettings: [String : Any] = [AVFormatIDKey: "kAudioFormatMPEG4AAC",
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

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        microphoneRecorder?.prepareToRecord()
        microphoneRecorder?.isMeteringEnabled = true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

