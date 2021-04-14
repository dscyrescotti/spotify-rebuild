//
//  AllCategories.swift
//  Spotify
//
//  Created by Dscyre Scotti on 14/04/2021.
//

import Foundation
import UIKit

struct AllCategories: Codable {
    let categories: Categories
}

struct Categories: Codable {
    let href: String
    let items: [CategoryItem]
    let limit: Int
    let next: String?
    let offset: Int
    let previous: String?
    let total: Int
}

struct CategoryItem: Codable {
    let href: String
    let icons: [Image]
    let id, name: String
    
    var model: CategoryCell.Model {
        .init(title: name, artworkURL: URL(string: icons.first?.url ?? ""))
    }
}
