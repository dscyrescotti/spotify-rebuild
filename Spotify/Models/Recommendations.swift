//
//  Recommendations.swift
//  Spotify
//
//  Created by Dscyre Scotti on 13/04/2021.
//

import Foundation

struct Recommendations: Codable {
    var tracks: [AudioTrack]
    var seeds: [Seed]
}

struct Seed: Codable {
    var initialPoolSize, afterFilteringSize, afterRelinkingSize: Int
    var id, type: String
    var href: String?
}

struct AudioTrack: Codable {
    var album: Album
    var artists: [Artist]
    var availableMarkets: [String]
    var discNumber, durationMS: Int
    var explicit: Bool
    var externalUrls: ExternalUrls
    var href: String
    var id: String
    var isLocal: Bool
    var name: String
    var previewURL: String?
    var trackNumber: Int
    var type, uri: String

    enum CodingKeys: String, CodingKey {
        case album, artists
        case availableMarkets = "available_markets"
        case discNumber = "disc_number"
        case durationMS = "duration_ms"
        case explicit
        case externalUrls = "external_urls"
        case href, id
        case isLocal = "is_local"
        case name
        case previewURL = "preview_url"
        case trackNumber = "track_number"
        case type, uri
    }
    var model: PlaylistTrackCell.Model {
        PlaylistTrackCell.Model(id: id, name: name, artist: artists.map { $0.name }.joined(separator: ", "), artworkURL: URL(string: album.images.first?.url ?? ""))
    }
    
    var albumTrack: AlbumTrackCell.Model {
        .init(id: id, name: name, artist: artists.map { $0.name }.joined(separator: ", "), artworkURL: URL(string: album.images.first?.url ?? ""))
    }
    
    var playerTrack: PlayerViewController.Model {
        .init(url: URL(string: album.images.first?.url ?? ""), title: name, subtitle: artists.map { $0.name }.joined(separator: ", "), hidesLabel: previewURL != nil)
    }
}

struct ExternalIDS: Codable {
    var isrc: String
}
