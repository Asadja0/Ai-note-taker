import Foundation

class AssemblyAIService {
    // Store API key securely - in production, use keychain or environment variables
    private let apiKey = "b4824b317db646129b1a281bd10d3b50"
    private let baseURL = "https://api.assemblyai.com/v2"
    
    // Add speaker roles mapping
    private var speakerRoles: [String: String] = [:]
    
    // Add custom speaker mapping
    private var customSpeakerNames: [String: String] = [
        "Host": "Host",
        "Guest 1": "Guest 1",
        "Guest 2": "Guest 2"
    ]

    // Upload audio file to AssemblyAI
    func uploadAudio(fileURL: URL, completion: @escaping (Result<String, Error>) -> Void) {
        var request = URLRequest(url: URL(string: "\(baseURL)/upload")!)
        request.httpMethod = "POST"
        request.setValue("\(apiKey)", forHTTPHeaderField: "authorization")
        
        do {
            let audioData = try Data(contentsOf: fileURL)
            request.httpBody = audioData
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let httpResponse = response as? HTTPURLResponse {
                    print("Upload Status Code: \(httpResponse.statusCode)")
                }
                
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Upload Response: \(responseString)")
                }
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let uploadURL = json["upload_url"] as? String else {
                    completion(.failure(NSError(domain: "AssemblyAI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))); return
                }
                
                completion(.success(uploadURL))
            }.resume()
        } catch {
            completion(.failure(error))
        }
    }
    
    // Update the transcription parameters to include speaker detection
    func transcribeAudio(uploadURL: String, completion: @escaping (Result<String, Error>) -> Void) {
        let parameters = TranscriptionParameters(
            audio_url: uploadURL,
            speaker_labels: true,  // Always enable speaker diarization
            speakers_expected: 3    // Expect 3 speakers: Host, Guest 1, Guest 2
        )
        
        var request = URLRequest(url: URL(string: "\(baseURL)/transcript")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.setValue("\(apiKey)", forHTTPHeaderField: "authorization")
        request.httpBody = try? JSONEncoder().encode(parameters)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("Transcribe Status Code: \(httpResponse.statusCode)")
            }
            
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Transcribe Response: \(responseString)")
            }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let id = json["id"] as? String else {
                completion(.failure(NSError(domain: "AssemblyAI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))); return
            }
            
            completion(.success(id))
        }.resume()
    }
    
    // Start transcription process with speaker recognition
    func transcribeAudioWithSpeakerRecognition(fileURL: URL, completion: @escaping (Result<String, Error>) -> Void) {
        // Create the upload request with speaker diarization enabled
        let parameters: [String: Any] = [
            "audio_url": fileURL.absoluteString,
            "speaker_labels": true,
            "speakers_expected": 2  // Adjust this based on expected number of speakers
        ]
        
        // Rest of your existing upload code remains the same
        var request = URLRequest(url: URL(string: "\(baseURL)/upload")!)
        request.httpMethod = "POST"
        request.setValue("\(apiKey)", forHTTPHeaderField: "authorization")
        
        do {
            let audioData = try Data(contentsOf: fileURL)
            request.httpBody = audioData
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let httpResponse = response as? HTTPURLResponse {
                    print("Upload Status Code: \(httpResponse.statusCode)")
                }
                
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Upload Response: \(responseString)")
                }
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let uploadURL = json["upload_url"] as? String else {
                    completion(.failure(NSError(domain: "AssemblyAI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))); return
                }
                
                completion(.success(uploadURL))
            }.resume()
        } catch {
            completion(.failure(error))
        }
    }
    
    // Check transcription status and get results
    func checkTranscriptionStatus(id: String, completion: @escaping (Result<TranscriptionResult, Error>) -> Void) {
        var request = URLRequest(url: URL(string: "\(baseURL)/transcript/\(id)")!)
        request.setValue("\(apiKey)", forHTTPHeaderField: "authorization")
        
        print("🔍 Checking transcription status for ID: \(id)")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Status Check Response Code: \(httpResponse.statusCode)")
            }
            
            if let error = error {
                print("❌ Status check error: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("❌ No data received")
                completion(.failure(NSError(domain: "AssemblyAI", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            // Print raw response for debugging
            print("\n🔍 Raw API Response:")
            if let responseString = String(data: data, encoding: .utf8) {
                print(responseString)
                print("\n")
            }
            
            do {
                var result = try JSONDecoder().decode(TranscriptionResult.self, from: data)
                
                // Process speaker roles if transcription is complete
                if result.status == "completed" && result.utterances != nil {
                    result = self?.processSpeakerRoles(result) ?? result
                }
                
                // Handle speaker information
                if let speakers = result.speakers {
                    print("Identified speakers: \(speakers.map { $0.name }.joined(separator: ", "))")
                }
                completion(.success(result))
            } catch {
                print("❌ Decoding error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }

    // Add helper method to identify speaker roles
    private func processSpeakerRoles(_ result: TranscriptionResult) -> TranscriptionResult {
        var updatedResult = result
        var speakerMap: [String: Int] = [:]
        
        // First pass: count speaker frequencies
        result.utterances?.forEach { utterance in
            speakerMap[utterance.speaker, default: 0] += 1
        }
        
        // Sort speakers by frequency (most frequent is likely the host)
        let sortedSpeakers = speakerMap.sorted { $0.value > $1.value }
        
        // Map speakers to roles
        var roleMapping: [String: String] = [:]
        for (index, speaker) in sortedSpeakers.enumerated() {
            switch index {
            case 0:
                roleMapping[speaker.key] = "Host"
            case 1:
                roleMapping[speaker.key] = "Guest 1"
            case 2:
                roleMapping[speaker.key] = "Guest 2"
            default:
                roleMapping[speaker.key] = "Additional Speaker \(index + 1)"
            }
        }
        
        // Update utterances with new speaker roles
        updatedResult.utterances = result.utterances?.map { utterance in
            var updated = utterance
            updated.speaker = roleMapping[utterance.speaker] ?? utterance.speaker
            return updated
        }
        
        return updatedResult
    }

    // Add method to update custom speaker names
    func updateCustomSpeakerName(role: String, name: String) {
        customSpeakerNames[role] = name
    }
}

// Models for transcription response
struct Speaker: Codable {
    let name: String
    let confidence: Double
}

struct UtteranceWithSpeaker: Codable {
    let text: String
    let speaker: String
    let start: Int
    let end: Int
}

struct TranscriptionParameters: Codable {
    let audio_url: String
    let speaker_labels: Bool
    let speakers_expected: Int
}

struct TranscriptionResult: Codable {
    let id: String
    let status: String
    let text: String?
    // Make utterances mutable
    var utterances: [Utterance]?
    var speakers: [Speaker]?
    var utterancesWithSpeakers: [UtteranceWithSpeaker]?
    
    private enum CodingKeys: String, CodingKey {
        case id, status, text
        case utterances
        case speakers
        case utterancesWithSpeakers
    }
}

struct Utterance: Codable {
    let text: String
    let start: Int
    let end: Int
    // Make speaker mutable
    var speaker: String
    
    private enum CodingKeys: String, CodingKey {
        case text, start, end, speaker
    }
}
