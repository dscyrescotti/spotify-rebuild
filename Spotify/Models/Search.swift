//
//  Search.swift
//  Spotify
//
//  Created by Dscyre Scotti on 15/04/2021.
//

import Foundation

struct Search: Codable {
    var artists: Artists
    var albums: Albums
    var playlists: Playlists
    var tracks: Tracks
}

struct Artists: Codable {
    var items: [Artist]
    var href: String
    var limit: Int
    var next: String?
    var offset: Int
    var previous: String?
    var total: Int
}

struct Tracks: Codable {
    var items: [AudioTrack]
    var href: String
    var limit: Int
    var next: String?
    var offset: Int
    var previous: String?
    var total: Int
}
