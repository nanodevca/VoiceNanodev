//
//  ContentView.swift
//  VoiceNanodev
//
//  Created by Roy Christo Ndjanfa Biaga on 2024-10-05.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var audioRecorder = AudioRecorder()
    
    var body: some View {
        VStack {

            Text("Voice Nanodev").bold().padding(10)
            Image(systemName: "ear")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            if audioRecorder.isRecording {
                Text("L'enregistrement a démarré...").padding()
            } else {
                Text("Appuyer pour démarrer l'enregistrement").padding()
            }

            HStack {
                Button(action: {
                    if !audioRecorder.isRecording {
                        audioRecorder.startRecording()
                    }
                }) {
                    Label("Start Recording", systemImage: "play.circle.fill").font(.title3).padding()
                }
                .cornerRadius(10)
                .disabled(audioRecorder.isRecording)
                
                Button(action: {
                    if audioRecorder.isRecording {
                        audioRecorder.stopRecording()
                    }
                }) {
                    Label("Stop Recording", systemImage: "pause.circle.fill").font(.title3).padding()
                }
                .cornerRadius(10)
                .disabled(!audioRecorder.isRecording)
            }
            
            // Affichage du temps d'enregistrement
            Text("Temps d'enregistrement : \(audioRecorder.formattedTime())")
                .font(.title)
                .padding()
            
            // Affichage du niveau de la voix
            EqualizerView(level: audioRecorder.voiceLevel)
                .padding()
            
            AudioSettingsView() // Affiche la vue des paramètres

        }
        .padding()
    }
}

#Preview {
    ContentView()
}
