//
//  AudioSettingsManager.swift
//  VoiceNanodev
//
//  Created by Roy Christo Ndjanfa Biaga on 2024-10-05.
//

import AVFoundation

class AudioSettingsManager: ObservableObject {
    @Published var availableMicrophones: [AVCaptureDevice] = []
    @Published var selectedMicrophone: AVCaptureDevice?
    @Published var inputVolume: Float = 1.0 // Volume par défaut

    init() {
        getAvailableMicrophones()
    }

    func getAvailableMicrophones() {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.microphone], mediaType: .audio, position: .unspecified)
        
        if let devices = discoverySession.devices as? [AVCaptureDevice] {
            self.availableMicrophones = devices
            
            if (self.selectedMicrophone == nil) {
                self.selectedMicrophone = devices.first // Micro par défaut
            }
        }
    }

    func setMicrophone(_ microphone: AVCaptureDevice) {
        self.selectedMicrophone = microphone
    }
}
