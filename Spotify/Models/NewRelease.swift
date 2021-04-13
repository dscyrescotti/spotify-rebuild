//
//  NewRelease.swift
//  Spotify
//
//  Created by Dscyre Scotti on 12/04/2021.
//

import Foundation

struct NewRelease: Codable {
    var albums: Albums
    var models: [NewReleaseCell.Model] {
        albums.items.map { NewReleaseCell.Model(id: $0.id, name: $0.name, artworkURL: URL(string: $0.images.first?.url ?? ""), totalTracks: $0.totalTracks, artistName: $0.artists.first?.name ?? "Unknown")}
    }
}

struct Albums: Codable {
    var href: String
    var items: [Album]
    var limit: Int
    var next: String?
    var offset: Int
    var previous: String?
    var total: Int
}

struct Album: Codable {
    var albumType: String
    var artists: [Artist]
    var availableMarkets: [String]
    var externalUrls: ExternalUrls
    var href: String
    var id: String
    var images: [Image]
    var name, type, uri: String
    var totalTracks: Int

    enum CodingKeys: String, CodingKey {
        case albumType = "album_type"
        case artists
        case availableMarkets = "available_markets"
        case externalUrls = "external_urls"
        case href, id, images, name, type, uri
        case totalTracks = "total_tracks"
    }
}

struct Artist: Codable {
    var externalUrls: ExternalUrls
    var href: String
    var id, name, type, uri: String

    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case href, id, name, type, uri
    }
}
