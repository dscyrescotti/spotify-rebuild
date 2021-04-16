//
//  PlaylistList.swift
//  Spotify
//
//  Created by Dscyre Scotti on 12/04/2021.
//

import Foundation

struct PlaylistList: Codable {
    var message: String?
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
    var snapshotID: String
    var type, uri: String

    enum CodingKeys: String, CodingKey {
        case collaborative
        case itemDescription = "description"
        case externalUrls = "external_urls"
        case href, id, images, name, owner
        case snapshotID = "snapshot_id"
        case type, uri
    }
    
    var model: FeaturePlaylistCell.Model {
        FeaturePlaylistCell.Model(id: id, name: name, artworkURL: URL(string: images.first?.url ?? ""), creator: owner.displayName ?? "Unknown")
    }
    
    var headerModel: PlaylistHeaderView.Model {
        .init(name: name, owner: owner.displayName ?? "Unknown", description: itemDescription, artworkURL: URL(string: images.first?.url ?? ""))
    }
    
    var libraryModel: LibraryCell.Model {
        .init(id: id, name: name, artworkURL: URL(string: images.first?.url ?? ""), creator: owner.displayName ?? "Unknown")
    }
}

struct Owner: Codable {
    var externalUrls: ExternalUrls
    var href: String
    var id, type, uri: String
    var displayName: String?

    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case href, id, type, uri
        case displayName = "display_name"
    }
}

//struct Tracks: Codable {
//    var href: String
//    var total: Int
//}

