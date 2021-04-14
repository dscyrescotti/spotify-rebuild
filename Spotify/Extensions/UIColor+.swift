//
//  UIColor+.swift
//  Spotify
//
//  Created by Dscyre Scotti on 14/04/2021.
//

import Foundation
import UIKit

extension UIColor {
    static var randomColor: UIColor {
        let colors: [UIColor] = [.systemRed, .systemBlue, .systemPink, .systemTeal, .systemGreen, .systemOrange, .systemYellow, .systemPurple, .systemIndigo]
        return colors.randomElement() ?? .systemGreen
    }
}
