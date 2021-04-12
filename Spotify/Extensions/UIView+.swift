//
//  UIView+.swift
//  Spotify
//
//  Created by Dscyre Scotti on 11/04/2021.
//

import Foundation
import UIKit

extension UIView {
    var width: CGFloat {
        self.frame.size.width
    }
    
    var height: CGFloat {
        self.frame.size.height
    }
    
    var left: CGFloat {
        self.frame.origin.x
    }
    
    var right: CGFloat {
        left + width
    }
    
    var top: CGFloat {
        self.frame.origin.y
    }
    
    var bottom: CGFloat {
        top + height
    }
}
