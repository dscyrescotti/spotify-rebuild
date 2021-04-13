//
//  BrowseCell.swift
//  Spotify
//
//  Created by Dscyre Scotti on 13/04/2021.
//

import Foundation
import UIKit

protocol BrowseCell: UICollectionViewCell {
    associatedtype Model
    static var identifier: String { get }
}

