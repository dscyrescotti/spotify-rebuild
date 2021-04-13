//
//  Playlist.swift
//  Spotify
//
//  Created by Dscyre Scotti on 11/04/2021.
//

import Foundation

struct PlaylistDetails: Codable {
    var collaborative: Bool
    var playlistDetailsDescription: String?
    var externalUrls: ExternalUrls
    var followers: Followers
    var href: String
    var id: String
    var images: [PlaylistDetailsImage]
    var name: String
    var owner: Owner?
    var playlistDetailsPublic: Bool
    var snapshotID: String
    var tracks: PlaylistTracks
    var type, uri: String

    enum CodingKeys: String, CodingKey {
        case collaborative
        case playlistDetailsDescription = "description"
        case externalUrls = "external_urls"
        case followers, href, id, images, name, owner
        case playlistDetailsPublic = "public"
        case snapshotID = "snapshot_id"
        case tracks, type, uri
    }
}

struct PlaylistTracks: Codable {
    var href: String
    var items: [PlaylistTrackItem]
    var limit: Int
    var next: String?
    var offset: Int
    var previous: String?
    var total: Int
}

struct PlaylistTrackItem: Codable {
    var addedAt: String
    var addedBy: Owner?
    var isLocal: Bool
    var track: PlaylistItem

    enum CodingKeys: String, CodingKey {
        case addedAt = "added_at"
        case addedBy = "added_by"
        case isLocal = "is_local"
        case track
    }
}

struct PlaylistItem: Codable {
    var album: PlaylistAlbum
    var artists: [Owner]
    var availableMarkets: [String]
    var discNumber, durationMS: Int
    var explicit: Bool
    var externalUrls: ExternalUrls
    var href: String
    var id, name: String
    var popularity: Int
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
        case href, id, name, popularity
        case previewURL = "preview_url"
        case trackNumber = "track_number"
        case type, uri
    }
}



struct PlaylistAlbum: Codable {
    var albumType: String
    var availableMarkets: [String]
    var externalUrls: ExternalUrls
    var href: String
    var id: String
    var images: [Image]
    var name, type, uri: String

    enum CodingKeys: String, CodingKey {
        case albumType = "album_type"
        case availableMarkets = "available_markets"
        case externalUrls = "external_urls"
        case href, id, images, name, type, uri
    }
}

struct PlaylistDetailsImage: Codable {
    var url: String
}


