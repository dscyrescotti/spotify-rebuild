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
    
    func getUserPlaylist(completion: @escaping (Result<Playlists, Error>) -> Void) {
        createRequest(url: URL(string: url(appending: "me/playlists")), method: .GET) { request in
            self.fetchData(Playlists.self, request: request, completion: completion)
        }
    }
    
    func getMePlaylist(completion: @escaping (Result<Playlists, Error>) -> Void) {
        getCurrentUserProfile { result in
            switch result {
            case .success(let profile):
                self.getUserPlaylist { result in
                    switch result {
                    case .success(let playlists):
                        var model = playlists
                        model.items = playlists.items.filter { $0.owner.uri == profile.uri }
                        completion(.success(model))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func createPlaylist(with name: String, completion: @escaping (Bool) -> Void) {
        getCurrentUserProfile { [weak self] result in
            switch result {
            case .success(let profile):
                self?.createRequest(url: URL(string: self?.url(appending: "users/\(profile.id)/playlists") ?? ""), method: .POST, completion: { request in
                    var request = request
                    request.httpBody = try? JSONSerialization.data(withJSONObject: ["name": name], options: .fragmentsAllowed)
                    self?.fetchData(request: request, completion: completion)
                })
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func addTrackToPlaylist(track: AudioTrack, playlist: Playlist, completion: @escaping (Bool) -> Void) {
        createRequest(url: URL(string: url(appending: "playlists/\(playlist.id)/tracks")), method: .POST) { request in
            var urlRequest = request
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: ["uris": ["spotify:track:\(track.id)"]], options: .fragmentsAllowed)
            self.fetchData(request: urlRequest, completion: completion)
        }
    }
    
    func removeTrackFromPlaylist(track: AudioTrack, playlist: Playlist, completion: @escaping (Bool) -> Void) {
        createRequest(url: URL(string: url(appending: "playlists/\(playlist.id)/tracks")), method: .DELETE) { request in
            var urlRequest = request
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: ["tracks": [["uri":"spotify:track:\(track.id)"]]], options: .fragmentsAllowed)
            self.fetchData(request: urlRequest, completion: completion)
        }
    }
    
    func getSearch(query: String, completion: @escaping (Result<Search, Error>) -> Void) {
        createRequest(url: URL(string: url(appending: "search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&type=album,artist,playlist,track")), method: .GET) { request in
            self.fetchData(Search.self, request: request, completion: completion)
        }
    }
    
    func getCategoryPlaylists(id: String, completion: @escaping (Result<PlaylistList, Error>) -> Void) {
        createRequest(url: URL(string: url(appending: "browse/categories/\(id)/playlists")), method: .GET) { request in
            self.fetchData(PlaylistList.self, request: request, completion: completion)
        }
    }
    
    func getAllCategories(completion: @escaping (Result<AllCategories, Error>) -> Void) {
        createRequest(url: URL(string: url(appending: "browse/categories?limit=50")), method: .GET) { request in
            self.fetchData(AllCategories.self, request: request, completion: completion)
        }
    }
    
    func getPlaylistDetails(playlist: Playlist, completion: @escaping (Result<PlaylistDetails, Error>) -> Void) {
        getCurrentUserProfile { result in
            switch result {
            case .success(let profile):
                self.createRequest(url: URL(string: self.url(appending: "playlists/\(playlist.id)")), method: .GET) { request in
                    self.fetchData(PlaylistDetails.self, request: request) { result in
                        switch result {
                        case .success(let model):
                            var details = model
                            if let owner = model.owner {
                                details.collaborative = owner.uri == profile.uri
                            }
                            completion(.success(details))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getUserAlbums(completion: @escaping (Result<LibraryAlbums, Error>) -> Void) {
        createRequest(url: URL(string: url(appending: "me/albums")), method: .GET) { request in
            self.fetchData(LibraryAlbums.self, request: request, completion: completion)
        }
    }
    
    func saveAlbum(id: String, completion: @escaping (Bool) -> Void) {
        createRequest(url: URL(string: url(appending: "me/albums?ids=\(id)")), method: .PUT) { request in
            var request = request
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            self.fetchData(request: request, completion: completion)
        }
    }
    
    func unsaveAlbum(id: String, completion: @escaping (Bool) -> Void) {
        createRequest(url: URL(string: url(appending: "me/albums?ids=\(id)")), method: .DELETE) { request in
            var request = request
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            self.fetchData(request: request, completion: completion)
        }
    }
    
    func getSavedAlbum(id: String, completion: @escaping (Result<[Bool], Error>) -> Void) {
        createRequest(url: URL(string: url(appending: "me/albums/contains?ids=\(id)")), method: .GET) { request in
            self.fetchData([Bool].self, request: request, completion: completion)
        }
    }
    
    func getAlbumDetails(album: Album, completion: @escaping (Result<AlbumDetails, Error>) -> Void) {
        createRequest(url: URL(string: url(appending: "albums/\(album.id)")), method: .GET) { request in
            self.fetchData(AlbumDetails.self, request: request, completion: completion)
        }
    }
    
    func getCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        createRequest(url: URL(string: url(appending: "me")), method: .GET) { request in
            self.fetchData(UserProfile.self, request: request, completion: completion)
        }
    }
    
    func getAllNewReleases(completion: @escaping (Result<NewRelease, Error>) -> Void) {
        createRequest(url: URL(string: url(appending: "browse/new-releases?limit=50")), method: .GET) { request in
            self.fetchData(NewRelease.self, request: request, completion: completion)
        }
    }
    
    func getFeaturePlaylists(completion: @escaping (Result<PlaylistList, Error>) -> Void) {
        createRequest(url: URL(string: url(appending: "browse/featured-playlists?limit=50")), method: .GET) { request in
            self.fetchData(PlaylistList.self, request: request, completion: completion)
        }
    }
    
    func getRecommendedGenres(completion: @escaping (Result<RecommendedGenres, Error>) -> Void) {
        createRequest(url: URL(string: url(appending: "recommendations/available-genre-seeds")), method: .GET) { request in
            self.fetchData(RecommendedGenres.self, request: request, completion: completion)
        }
    }
    
    func getRecommendations(genres: Set<String>, completion: @escaping (Result<Recommendations, Error>) -> Void) {
        let seeds = genres.joined(separator: ",")
        createRequest(url: URL(string: url(appending: "recommendations?seed_genres=\(seeds)")), method: .GET) { request in
            self.fetchData(Recommendations.self, request: request, completion: completion)
        }
    }
    
    private func fetchData<T: Codable>(_ type: T.Type, request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
            guard let data = data, error == nil else {
                completion(.failure(ApiError.unableToFetch))
                return
            }
            do {
                let model = try JSONDecoder().decode(type, from: data)
                completion(.success(model))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    private func fetchData(request: URLRequest, completion: @escaping (Bool) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let _ = data, error == nil else {
                completion(false)
                return
            }
           completion(true)
        }
        task.resume()
    }
    
    enum URLMethod: String {
        case GET
        case POST
        case DELETE
        case PUT
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
