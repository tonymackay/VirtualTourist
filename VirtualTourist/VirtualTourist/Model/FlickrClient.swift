//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Tony Mackay on 08/05/2020.
//  Copyright © 2020 ViewModel Software. All rights reserved.
//

import Foundation

struct PhotoInfo: Codable {
    let id: String
    let server: String
    let farm: Int
    let secret: String
    
    var url: String {
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
    }
}

struct PhotoList: Codable {
    let pages: Int
    let total: String
    let photo: [PhotoInfo]
}

struct PhotoResponse: Codable {
    let photos: PhotoList
}

class FlickrClient {
    
    struct Auth {
        static var apiKey = ""
    }
    
    enum Endpoints {
        static let base = "https://www.flickr.com/services/rest/?format=json&nojsoncallback=1"
        
        case search(lat: Double, lon: Double, page: Int)
        
        var stringValue: String {
            switch self {
            case .search(let lat, let lon, let page):
                return Endpoints.base + "&method=flickr.photos.search&per_page=20&api_key=\(Auth.apiKey)&lat=\(lat)&lon=\(lon)&page=\(page)"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    @discardableResult
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            print(String(data: data, encoding: .utf8) ?? "")
            
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
        return task
    }
    
    class func search(latitude: Double, longitude: Double, page: Int = 1, completion: @escaping (PhotoResponse?, Error?) -> Void) {
        let url = Endpoints.search(lat: latitude, lon: longitude, page: page).url
        taskForGETRequest(url: url, responseType: PhotoResponse.self) { response, error in
            if let response = response {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    class func download(url: String, completion: @escaping (Data?, Error?) -> Void) {
        guard let url = URL(string: url) else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            DispatchQueue.main.async {
                completion(data, nil)
            }
        }
        task.resume()
    }
}
