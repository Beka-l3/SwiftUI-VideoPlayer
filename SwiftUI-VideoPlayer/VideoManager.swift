//
//  VideoManager.swift
//  SwiftUI-VideoPlayer
//
//  Created by Bekzhan Talgat on 01.07.2023.
//

import Foundation

enum Query: String, CaseIterable {
    case ocean, nature, animals, people, food
}

class VideoManager: ObservableObject {
    @Published private(set) var videos: [Video] = []
    @Published var selectedQuery: Query = .ocean {
        didSet {
            Task {
                do {
                    try await findVideos(query: selectedQuery)
                } catch {
                    print("Error: \(error)")
                }
            }
        }
    }
    
    init() {
        Task {
            do {
                try await findVideos(query: selectedQuery)
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    func findVideos(query: Query) async throws {
        await MainActor.run {
            self.videos = []
//            self.videos = decodedData.videos
        }
        
        do {
            guard let url = URL(string: "https://api.pexels.com/videos/search?query=\(query.rawValue)&per_page=10&orientation=portrait") else {
                throw ServiceError.missingURL
            }
            
            var urlRequest = URLRequest(url: url)
            urlRequest.setValue("VbhLWQjKSfwmnMmsPv7HOgAXIc0nJmSn0dTdk2MAE3hqHTxFJZGUyT5o", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                throw ServiceError.failure
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let decodedData = try decoder.decode(ResponseBody.self, from: data)
            
            await MainActor.run {
//                self.videos = []
                self.videos = decodedData.videos
            }
            
            print( "Success for \(self.selectedQuery)\n" )
        } catch {
            print("\n\nerro fetching from pexels: \(error)\n\n")
            throw error
        }
    }
    
    enum ServiceError: Error {
        case fetchingError, missingURL, failure
    }
}


struct ResponseBody: Decodable {
    let page: Int
    let perPage: Int
    let totalResults: Int
    let url: String
    let videos: [Video]
}

struct Video: Identifiable, Decodable {
    let id: Int
    
//    let width: Int
//    let heght: Int
//    let url: String
    let image: String
    let duration: Int
    let user: User
    let videoFiles: [VideoFile]
    
    struct User: Decodable {
        let id: Int
            
        let name: String
        let url: String
        
        static let zero: User = .init(id: 0, name: "XYZ", url: "")
    }

    struct VideoFile: Identifiable, Decodable {
        let id: Int
        
        let quality: String
        let fileType: String
    //    let width: Int
    //    let height: Int
        let link: String
    }
    
    static let zero: Video = .init(id: 0, image: "", duration: 99, user: .zero, videoFiles: [])
}


