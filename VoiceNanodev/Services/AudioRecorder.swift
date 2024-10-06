//
//  AudioRecorder.swift
//  VoiceNanodev
//
//  Created by Roy Christo Ndjanfa Biaga on 2024-10-05.
//
import Cocoa
import AVFoundation

class AudioRecorder: NSObject, NSApplicationDelegate, ObservableObject {
    static let shared = AudioRecorder()
    
    @IBOutlet weak var window: NSWindow!
    
    var audioEngine: AVAudioEngine! = AVAudioEngine()
    var audioFile: AVAudioFile? = nil
    private var timer: Timer?
    private var audioBufferQueue = Data()
    private let bufferThreshold = 512
    let BUFFER_SIZE: UInt32 = 1024
    
    @Published var isRecording = false
    @Published var recordingTime: TimeInterval = 0.0 // Temps d'enregistrement
    @Published var voiceLevel: Float = 0.0 // Niveau de la voix
    
    @Published var isRecordReady = false
    
    func startRecording() {
        // If sandboxed (coding), don't forget to turn on Microphone in Capabilities > App Sandbox
        let input = audioEngine.inputNode
            let bus = 0
            let inputFormat = input.inputFormat(forBus: bus)

            input.installTap(onBus: bus, bufferSize: BUFFER_SIZE, format: inputFormat) { (buffer, time) in
                let audioData = self.convertBufferToData(buffer: buffer, format: inputFormat)
                self.audioBufferQueue.append(audioData)
                
                if self.audioBufferQueue.count >= self.bufferThreshold {
                    self.streamAudioToElevenLabs(audioData: self.audioBufferQueue)
                    self.audioBufferQueue.removeAll() // Clear the buffer
                }

                self.analyzeAudio(buffer: buffer) // For visual feedback
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
    
    private func convertBufferToData(buffer: AVAudioPCMBuffer, format: AVAudioFormat) -> Data {
        let audioBuffer = buffer.audioBufferList.pointee.mBuffers
        let audioData = Data(bytes: audioBuffer.mData!, count: Int(audioBuffer.mDataByteSize))
        return audioData
    }
    
    func streamAudioToElevenLabs(audioData: Data) {
        VoiceConvertion.shared.convert(
            audio: audioData,
            sourceLanguage: "fr",
            targetLanguage: "fr",
            targetVoiceId: "T1Mmvjng3xi6OmMB1oGc"
        ) { result in
            switch result {
            case .success(let translatedAudio):
                // Play or handle the translated audio in real-time
                print("Real-time voice conversion successful!")
                
            case .failure(let error):
                print("Voice conversion failed: \(error.localizedDescription)")
            }
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

            // Now we convert the recorded audio to a different voice
            convertRecordedVoice()
        }
    }
    
    private func convertRecordedVoice() {
        let fileURL = getFileURL()
        
        do {
            let audioData = try Data(contentsOf: fileURL) // Load audio file as data
            
            VoiceConvertion.shared.convert(
                audio: audioData,
                sourceLanguage: "fr",
                targetLanguage: "fr",
                targetVoiceId: "T1Mmvjng3xi6OmMB1oGc"
            ) { result in
                switch result {
                case .success(let translatedAudio):
                    // Handle the translated audio, for example, save it or play it
                    self.saveTranslatedAudio(data: translatedAudio)
                    self.isRecordReady = true
                    print("Voice conversion successful!")
                    
                case .failure(let error):
                    print("Voice conversion failed: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Error reading recorded audio: \(error.localizedDescription)")
        }
    }
    
    private func saveTranslatedAudio(data: Data) {
        let outputURL = self.getFileURL(filename: "ConvertedRecord.caf")
        
        do {
            try data.write(to: outputURL)
            print("Translated voice saved to: \(outputURL.path)")
        } catch {
            print("Error saving translated voice: \(error.localizedDescription)")
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
    
    func getFileURL(filename: String = "recording.caf") -> URL {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentDirectory.appendingPathComponent(filename) // On utilise caf car c'est plus facile à manipuler pour une conversion ultérieur si nécessaire
    }
    
}
