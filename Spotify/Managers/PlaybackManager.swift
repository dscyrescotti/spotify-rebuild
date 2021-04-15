//
//  PlaybackManager.swift
//  Spotify
//
//  Created by Dscyre Scotti on 15/04/2021.
//

import Foundation
import UIKit

final class PlaybackManager {
    
    static let shared = PlaybackManager()
    
    private init() { }
    
    func startPlayback(_ viewController: UIViewController, track: AudioTrack) {
        let vc = PlayerViewController()
        vc.title = track.name
        viewController.present(UINavigationController(rootViewController: vc), animated: true)
    }
    
    func startPlayback(_ viewController: UIViewController, tracks: [AudioTrack]) {
        let vc = PlayerViewController()
        vc.title = tracks.first?.name
        viewController.present(UINavigationController(rootViewController: vc), animated: true)
    }
}
