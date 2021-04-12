//
//  ApiManager.swift
//  Spotify
//
//  Created by Dscyre Scotti on 11/04/2021.
//

import Foundation

final class ApiManger {
    static let shared = ApiManger()
    
    private let baseURL = "https://api.spotify.com/v1/"
    
    private init() { }
    
    enum ApiError: Error {
        case unableToFetch
    }
    
    func getCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        createRequest(url: URL(string: url(appending: "me")), method: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { (data, _, error) in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.unableToFetch))
                    return
                }
                do {
                    let profile = try JSONDecoder().decode(UserProfile.self, from: data)
                    completion(.success(profile))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    func getAllNewReleases(completion: @escaping (Result<NewRelease, Error>) -> Void) {
        createRequest(url: URL(string: url(appending: "browse/new-releases?limit=50")), method: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { (data, _, error) in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.unableToFetch))
                    return
                }
                do {
                    let newRelease = try JSONDecoder().decode(NewRelease.self, from: data)
                    completion(.success(newRelease))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    func getFeaturePlaylists(completion: @escaping (Result<FeaturePlaylist, Error>) -> Void) {
        createRequest(url: URL(string: url(appending: "browse/featured-playlists?limit=50")), method: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { (data, _, error) in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.unableToFetch))
                    return
                }
                do { 
                    let playlists = try JSONDecoder().decode(FeaturePlaylist.self, from: data)
                    completion(.success(playlists))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    func getRecommendedGenres(completion: @escaping (Result<RecommendedGenres, Error>) -> Void) {
        createRequest(url: URL(string: url(appending: "recommendations/available-genre-seeds")), method: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { (data, _, error) in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.unableToFetch))
                    return
                }
                do {
                    let genres = try JSONDecoder().decode(RecommendedGenres.self, from: data)
                    completion(.success(genres))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    func getRecommendations(genres: Set<String>, completion: @escaping (Result<RecommendedGenres, Error>) -> Void) {
        let seeds = genres.joined(separator: ",")
        createRequest(url: URL(string: url(appending: "recommendations?seed_genres=\(seeds)&limit=1")), method: .GET) { baseRequest in
            print(baseRequest.url?.absoluteString)
            let task = URLSession.shared.dataTask(with: baseRequest) { (data, _, error) in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.unableToFetch))
                    return
                }
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    print(json)
//                        JSONDecoder().decode(RecommendedGenres.self, from: data)
//                    completion(.success(playlists))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    enum URLMethod: String {
        case GET
        case POST
    }
    
    private func createRequest(url: URL?, method: URLMethod, completion: @escaping (URLRequest) -> Void) {
        AuthManager.shared.withValidToken { token in
            guard let url = url else { return }
            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = method.rawValue
            request.timeoutInterval = 30
            completion(request)
        }
    }
    
    private func url(appending string: String) -> String {
        baseURL + string
    }
}
