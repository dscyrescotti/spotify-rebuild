//
//  AlbumDetails.swift
//  Spotify
//
//  Created by Dscyre Scotti on 13/04/2021.
//

import Foundation
import CodableX

struct AlbumDetails: Codable {
    var albumType: String
    var artists: [Artist]
    var availableMarkets: [String]
    var copyrights: [Copyright]
    var externalUrls: ExternalUrls
    var href: String
    var id: String
    var images: [Image]
    var name: String
    var popularity: Int
    var releaseDate, releaseDatePrecision: String
    var tracks: AlbumTracks
    var type, uri: String

    enum CodingKeys: String, CodingKey {
        case albumType = "album_type"
        case artists
        case availableMarkets = "available_markets"
        case copyrights
        case externalUrls = "external_urls"
        case href, id, images, name, popularity
        case releaseDate = "release_date"
        case releaseDatePrecision = "release_date_precision"
        case tracks
        case type, uri
    }
    
    var audioTracks: [AudioTrack] {
        tracks.items.map { AudioTrack.init(album: Album.init(albumType: albumType, artists: artists, availableMarkets: availableMarkets, externalUrls: externalUrls, href: href, id: id, images: images, name: name, type: type, uri: uri, totalTracks: tracks.items.count, releaseDate: releaseDate), artists: $0.artists, availableMarkets: $0.availableMarkets, discNumber: $0.durationMS, durationMS: $0.durationMS, explicit: $0.explicit, externalUrls: $0.externalUrls, href: $0.href, id: $0.id, isLocal: false, name: $0.name, previewURL: $0.previewURL, trackNumber: $0.trackNumber, type: $0.type, uri: $0.uri) }
    }
}

struct Copyright: Codable {
    var text, type: String
}

struct AlbumTracks: Codable {
    var href: String
    var items: [AlbumTrackItem]
    var limit: Int
    var next: String?
    var offset: Int
    var previous: String?
    var total: Int
}

struct AlbumTrackItem: Codable {
    var artists: [Artist]
    var availableMarkets: [String]
    var discNumber, durationMS: Int
    var explicit: Bool
    var externalUrls: ExternalUrls
    var href: String
    var id, name: String
    var previewURL: String?
    var trackNumber: Int
    var type, uri: String

    enum CodingKeys: String, CodingKey {
        case artists
        case availableMarkets = "available_markets"
        case discNumber = "disc_number"
        case durationMS = "duration_ms"
        case explicit
        case externalUrls = "external_urls"
        case href, id, name
        case previewURL = "preview_url"
        case trackNumber = "track_number"
        case type, uri
    }
    var model: AlbumTrackCell.Model {
        .init(id: id, name: name, artist: artists.map { $0.name }.joined(separator: ", "), artworkURL: nil)
    }
}
