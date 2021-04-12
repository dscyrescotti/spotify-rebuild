//
//  FeaturePlaylist.swift
//  Spotify
//
//  Created by Dscyre Scotti on 12/04/2021.
//

import Foundation

struct FeaturePlaylist: Codable {
    var message: String
    var playlists: Playlists
}

struct Playlists: Codable {
    var href: String
    var items: [Playlist]
    var limit: Int
    var next: String?
    var offset: Int
    var previous: String?
    var total: Int
}

struct Playlist: Codable {
    var collaborative: Bool
    var itemDescription: String
    var externalUrls: ExternalUrls
    var href: String
    var id: String
    var images: [Image]
    var name: String
    var owner: Owner
//    var itemPublic: String?
    var snapshotID: String
    var tracks: Tracks
    var type, uri: String

    enum CodingKeys: String, CodingKey {
        case collaborative
        case itemDescription = "description"
        case externalUrls = "external_urls"
        case href, id, images, name, owner
//        case itemPublic = "public"
        case snapshotID = "snapshot_id"
        case tracks, type, uri
    }
}

struct Owner: Codable {
    var externalUrls: ExternalUrls
    var href: String
    var id, type, uri: String

    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case href, id, type, uri
    }
}

struct Tracks: Codable {
    var href: String
    var total: Int
}
