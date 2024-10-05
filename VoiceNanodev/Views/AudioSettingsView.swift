//
//  AudioSettingsView.swift
//  VoiceNanodev
//
//  Created by Roy Christo Ndjanfa Biaga on 2024-10-05.
//

import SwiftUI
import AVFoundation

struct AudioSettingsView: View {
    @ObservedObject var audioSettings = AudioSettingsManager()

    var body: some View {
        VStack {
            Text("Paramètres audio").font(.headline).padding()

            // Sélection des micros
            Picker("Microphone", selection: $audioSettings.selectedMicrophone) {
                ForEach(audioSettings.availableMicrophones, id: \.self) { microphone in
                    Text(microphone.localizedName).tag(microphone as AVCaptureDevice?)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: audioSettings.selectedMicrophone) { newMic in
                if let mic = newMic {
                    audioSettings.setMicrophone(mic)
                }
            }
            .padding()

            Spacer()
        }
        .padding()
    }
}
