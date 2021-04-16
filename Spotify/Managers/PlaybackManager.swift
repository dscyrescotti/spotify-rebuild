//
//  PlaybackManager.swift
//  Spotify
//
//  Created by Dscyre Scotti on 15/04/2021.
//

import Foundation
import UIKit
import AVFoundation

protocol PlaybackManagerDelegate {
    func moveToNextTrack()
}

final class PlaybackManager {
    
    static let shared = PlaybackManager()
    
    private var player: AVPlayer?
    
    private var tracks: [AudioTrack] = []
    private var currentTrack: AudioTrack?
    
    var isPlaying = false
    private var volume: Float = 0.5
    
    var delegate: PlaybackManagerDelegate?
    
    private init() { }
    
    func startPlayback(_ viewController: UIViewController, track: AudioTrack?, tracks: [AudioTrack]) {
        self.tracks = tracks
        self.currentTrack = track
        let vc = PlayerViewController()
        vc.configure(model: currentTrack?.playerTrack)
        NotificationCenter.default.addObserver(self, selector: #selector(trackEnd), name:
        NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        viewController.present(UINavigationController(rootViewController: vc), animated: true) { [weak self] in
            self?.startPlay()
        }
    }
    
    @objc func trackEnd() {
        forward()
        delegate?.moveToNextTrack()
    }
    
    private func startPlay() {
        player = nil
        guard let previewURL = currentTrack?.previewURL, let url = URL(string: previewURL) else {
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 5) {
                DispatchQueue.main.async {
                    self.trackEnd()
                }
            }
            return
        }
        player = AVPlayer(url: url)
        player?.volume = volume
        player?.play()
    }
    
    func play() {
        if isPlaying {
            player?.pause()
            isPlaying.toggle()
        } else {
            player?.play()
            isPlaying.toggle()
        }
    }
    
    func forward() {
        guard let index = getCurrentIndex() else { return }
        var trackIndex: Int
        if index + 1 > tracks.count - 1 {
            trackIndex = 0
        } else {
            trackIndex = index + 1
        }
        let track = tracks[trackIndex]
        currentTrack = track
        startPlay()
    }
    
    func backward() {
        guard let index = getCurrentIndex() else { return }
        var trackIndex: Int
        if index - 1 < 0 {
            trackIndex = tracks.count - 1
        } else {
            trackIndex = index - 1
        }
        let track = tracks[trackIndex]
        currentTrack = track
        startPlay()
    }
    
    private func getCurrentIndex() -> Array<AudioTrack>.Index? {
        guard let track = currentTrack, let index = tracks.firstIndex(where: { $0.id == track.id }) else { return nil }
        return index
    }
    
    func configure(completion: @escaping (PlayerViewController.Model?) -> Void) {
        completion(currentTrack?.playerTrack)
    }
    
    func changeVolume(value: Float) {
        volume = value
        player?.volume = volume
    }
    
}
