//
//  AudioRecorder.swift
//  VoiceNanodev
//
//  Created by Roy Christo Ndjanfa Biaga on 2024-10-05.
//
import Cocoa
import AVFoundation

class AudioRecorder: NSObject, NSApplicationDelegate, ObservableObject {
    
    @IBOutlet weak var window: NSWindow!
    
    var audioEngine: AVAudioEngine! = AVAudioEngine()
    var audioFile: AVAudioFile? = nil
    @Published var isRecording = false
    
    func startRecording() {
        // If sandboxed (coding), don't forget to turn on Microphone in Capabilities > App Sandbox
        let input = audioEngine.inputNode
        let bus = 0
        let inputFormat = input.inputFormat(forBus: bus)

        let outputURL = getFileURL()
        print("Fichier audio enregistré à : \(outputURL.path)")
        
        audioFile = try! AVAudioFile(forWriting: outputURL, settings: inputFormat.settings, commonFormat: inputFormat.commonFormat, interleaved: inputFormat.isInterleaved)

        input.installTap(onBus: bus, bufferSize: 512, format: inputFormat) { (buffer, time) in
            try! self.audioFile?.write(from: buffer)
        }
        
        do {
            try self.audioEngine.start()
            self.isRecording = true
            print("Enregistrement démarré")
        } catch {
            print("Erreur lors du démarrage de l'audioEngine: \(error.localizedDescription)")
        }
    }

    func stopRecording() {
        if isRecording {
            self.audioEngine.stop()
            self.audioEngine.inputNode.removeTap(onBus: 0)
            self.audioFile = nil
            self.isRecording = false
            print("Enregistrement arrêté")
        }
    }

    func getFileURL() -> URL {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentDirectory.appendingPathComponent("recording.caf") // On utilise WAV car c'est plus facile à manipuler pour une conversion ultérieur si nécessaire
    }
}

