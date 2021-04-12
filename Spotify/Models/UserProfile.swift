//
//  UserProfile.swift
//  Spotify
//
//  Created by Dscyre Scotti on 11/04/2021.
//

import Foundation

struct UserProfile: Codable {
    var country, displayName, email: String
    var externalUrls: ExternalUrls
    var followers: Followers
    var href: String
    var id: String
    var images: [Image]
    var product, type, uri: String
    var explicitContent: [String: Bool]

    enum CodingKeys: String, CodingKey {
        case country
        case displayName = "display_name"
        case email
        case externalUrls = "external_urls"
        case href, id, product, type, uri
        case images, followers
        case explicitContent = "explicit_content"
    }
    
    struct Row {
        var title: String
        var description: String
        var data: String {
            "\(title): \(description)"
        }
    }
    
    var toRows: [Row] {
        [.init(title: "Full Name", description: displayName), .init(title: "Email Address", description: email), .init(title: "User ID", description: id), .init(title: "Plan", description: product)]
    }
}

struct ExternalUrls: Codable {
    var spotify: String
}

struct Followers: Codable {
    var href: String?
    var total: Int
}

struct Image: Codable {
    var height: Int?
    var url: String
    var width: Int?
}
