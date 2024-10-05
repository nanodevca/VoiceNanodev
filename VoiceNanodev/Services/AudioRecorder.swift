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
    
    @Published var recordingTime: TimeInterval = 0.0 // Temps d'enregistrement

    private var timer: Timer?
    
    @Published var voiceLevel: Float = 0.0 // Niveau de la voix
    
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
            self.analyzeAudio(buffer: buffer)
        }
        
        do {
            try self.audioEngine.start()
            startTimer()
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
            
            stopTimer()
            self.isRecording = false
            print("Enregistrement arrêté")
        }
    }
    
    private func startTimer() {
        recordingTime = 0.0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.recordingTime += 1
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func formattedTime() -> String {
        let minutes = Int(recordingTime) / 60
        let seconds = Int(recordingTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // Analyser les niveaux audio dans le buffer
    private func analyzeAudio(buffer: AVAudioPCMBuffer) {
        let channelData = buffer.floatChannelData![0]
        let channelDataValueArray = stride(from: 0, to: Int(buffer.frameLength), by: buffer.stride).map { channelData[$0] }
        let rms = sqrt(channelDataValueArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
        let avgPower = 20 * log10(rms)
        
        DispatchQueue.main.async {
            self.voiceLevel = max(0.0, min(1.0, (avgPower + 50) / 50)) // Normaliser entre 0 et 1
        }
    }
    
    func getFileURL() -> URL {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentDirectory.appendingPathComponent("recording.caf") // On utilise caf car c'est plus facile à manipuler pour une conversion ultérieur si nécessaire
    }
}

