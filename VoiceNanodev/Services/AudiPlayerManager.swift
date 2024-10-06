//
//  AudiPlayerManager.swift
//  VoiceNanodev
//
//  Created by Roy Christo Ndjanfa Biaga on 2024-10-06.
//

import AVFoundation

class AudioPlayerManager: ObservableObject {
    var audioPlayer: AVAudioPlayer?

    func playAudio() {
        let url = AudioRecorder.shared.getFileURL(filename: "ConvertedRecord.caf")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Erreur lors de la lecture du fichier audio : \(error.localizedDescription)")
        }
    }
}
