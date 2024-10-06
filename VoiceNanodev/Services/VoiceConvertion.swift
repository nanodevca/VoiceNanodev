//
//  VoiceConvertion.swift
//  VoiceNanodev
//
//  Created by Edouard Yonga on 05/10/2024.
//

import Foundation

class VoiceConvertion {
    static let shared = VoiceConvertion()

    let apiKey: String = "sk_655416429ec2c304f3155fdb77b75fa63f68fbc5f6e5524e"
    
    func convert(audio: Data, sourceLanguage: String, targetLanguage: String, targetVoiceId: String, completion: @escaping (Result<Data, Error>) -> Void) {
        
        guard !apiKey.isEmpty else {
            return completion(.failure(NSError(domain: "ElevenLabsSpeechServiceError", code: 0, userInfo: ["message": "API Key Required"])))
        }
        
        guard let url = URL(string: "https://api.elevenlabs.io/v1/speech-to-speech/\(targetVoiceId)/stream") else {
            return completion(.failure(NSError(domain: "ElevenLabsSpeechServiceError", code: 1, userInfo: ["message": "Invalid URL"])))
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "xi-api-key")
        request.setValue("audio/mpeg", forHTTPHeaderField: "Accept")

        // Create multipart/form-data body
        let body = createMultipartBody(boundary: boundary, audio: audio, sourceLanguage: sourceLanguage, targetLanguage: targetLanguage)
        request.httpBody = body

        // Perform the network request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data {
                completion(.success(data))
            } else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                completion(.failure(NSError(domain: "ElevenLabsSpeechServiceError", code: statusCode, userInfo: ["message": "Request failed with status code: \(statusCode)"])))
            }
        }.resume()
    }

    private func createMultipartBody(boundary: String, audio: Data, sourceLanguage: String, targetLanguage: String) -> Data {
        let body = NSMutableData()
        let json: [String: Any] = ["source_language": sourceLanguage, "target_language": targetLanguage, "model_id": "eleven_turbo_v2_5"]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"metadata\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
            body.append(jsonData)
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"audio\"; filename=\"audio.wav\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/wav\r\n\r\n".data(using: .utf8)!)
        body.append(audio)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        return body as Data
    }
}
