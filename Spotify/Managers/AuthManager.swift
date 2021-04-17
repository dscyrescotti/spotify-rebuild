//
//  AuthManager.swift
//  Spotify
//
//  Created by Dscyre Scotti on 11/04/2021.
//

import Foundation
import KeychainAccess

final class AuthManager {
    static let shared = AuthManager()
    private let keychain = Keychain(service: "app.dscyrescotti.Spotify")
    
    private var refreshingToken = false
    
    private init() {
        refreshIfNeeded { _ in }
    }
    
    var signInURL: URL? {
        let scope = "user-read-private%20playlist-modify-public%20playlist-modify-private%20playlist-read-private%20user-follow-read%20user-library-modify%20user-library-read%20user-read-email"
        let base = "https://accounts.spotify.com/authorize"
        let stringURL = "\(base)?response_type=code&client_id=\(Credentials.clientId)&scope=\(scope)&redirect_uri=\(Credentials.redirectURI)&show_dialog=true"
        return URL(string: stringURL)
    }
    
    func tokenApiURL(code: String) -> URL? {
        let base = "https://accounts.spotify.com/api/token"
        guard var components = URLComponents(string: base) else { return nil }
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: Credentials.redirectURI),
        ]
        return components.url
    }
    
    func refreshTokenURL(token: String) -> URL? {
        let base = "https://accounts.spotify.com/api/token"
        guard var components = URLComponents(string: base) else { return nil }
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: token),
        ]
        return components.url
    }
    
    var isSignedIn: Bool {
        accessToken != nil
    }
    
    private var accessToken: String? {
        try? keychain.get(KeychainKeys.access_token.rawValue)
    }
    
    private var refreshToken: String? {
        try? keychain.get(KeychainKeys.refresh_token.rawValue)
    }
    
    private var tokenExpirationDate: Date? {
        UserDefaults.standard.object(forKey: KeychainKeys.expiration_date.rawValue) as? Date
    }
    
    private var shouldRefreshToken: Bool {
        guard let expiredDate = tokenExpirationDate else { return false }
        let currentDate = Date()
        let fiveMins = TimeInterval(300)
        return currentDate.addingTimeInterval(fiveMins) >= expiredDate
    }
    
    private struct Credentials {
        static let clientId = "12068163f4714f308bc2bb649c69e264"
        static let clientSecret = "8dcafbd92dde4c1ba64149c118698067"
        static let redirectURI = "https://github.com/dscyrescotti/spotify-rebuild"
    }
    
    private struct AuthResult: Codable {
        var accessToken: String
        var expiresIn: Int
        var refreshToken: String?
        var scope, tokenType: String

        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case expiresIn = "expires_in"
            case refreshToken = "refresh_token"
            case scope
            case tokenType = "token_type"
        }
    }
    
    private enum KeychainKeys: String {
        case access_token, expiration_date, refresh_token
    }
    
    func exchangeCodeForToken(code: String, completion: @escaping ((Bool) -> Void)) {
        guard let url = tokenApiURL(code: code) else {
            print("No token api url")
            completion(false)
            return
        }
        guard let base64String = "\(Credentials.clientId):\(Credentials.clientSecret)".data(using: .utf8)?.base64EncodedString() else {
            completion(false)
            return
        }
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, _, error) in
            guard let data = data, error == nil else {
                print("Got error")
                completion(false)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(AuthResult.self, from: data)
                try self?.cacheToken(result: result)
                completion(true)
            } catch {
                print("Error")
                print(error.localizedDescription)
                completion(false)
            }
        }
        task.resume()
    }
    
    func signOut(completion: () -> Void) {
        try? keychain.remove(KeychainKeys.access_token.rawValue)
        try? keychain.remove(KeychainKeys.refresh_token.rawValue)
        UserDefaults.standard.setValue(nil, forKey: KeychainKeys.expiration_date.rawValue)
        completion()
    }
    
    private func cacheToken(result: AuthResult) throws {
        try keychain.set(result.accessToken, key: KeychainKeys.access_token.rawValue)
        if let refreshToken = result.refreshToken {
            try keychain.set(refreshToken, key: KeychainKeys.refresh_token.rawValue)
        }
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expiresIn)), forKey: KeychainKeys.expiration_date.rawValue)
    }
    
    private var onRefreshingBlocks: [(String) -> Void] = []
    
    func withValidToken(completion: @escaping (String) -> Void) {
        guard !refreshingToken else {
            onRefreshingBlocks.append(completion)
            return
        }
        if shouldRefreshToken {
            refreshIfNeeded { [weak self] success in
                if let token = self?.accessToken {
                    completion(token)
                }
            }
        } else if let token = self.accessToken {
            completion(token)
        }
    }
    
    func refreshIfNeeded(completion: @escaping (Bool) -> Void) {
        guard !refreshingToken else { return }
        guard shouldRefreshToken else {
            completion(true)
            return
        }
        guard let refreshToken = refreshToken else {
            return
        }
        guard let url = refreshTokenURL(token: refreshToken) else {
            completion(false)
            return
        }
        guard let base64String = "\(Credentials.clientId):\(Credentials.clientSecret)".data(using: .utf8)?.base64EncodedString() else {
            completion(false)
            return
        }
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        refreshingToken = true
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, _, error) in
            self?.refreshingToken = false
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(AuthResult.self, from: data)
                try self?.cacheToken(result: result)
                self?.onRefreshingBlocks.forEach { $0(result.accessToken) }
                self?.onRefreshingBlocks.removeAll()
                completion(true)
            } catch {
                print(error.localizedDescription)
                completion(false)
            }
        }
        task.resume()
    }
}
