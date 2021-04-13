//
//  PlaylistViewController.swift
//  Spotify
//
//  Created by Dscyre Scotti on 11/04/2021.
//

import UIKit

class PlaylistViewController: UIViewController {
    
    private let playlist: Playlist
    
    init(playlist: Playlist) {
        self.playlist = playlist
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchData()
        setUp()
    }
}

extension PlaylistViewController {
    func setUp() {
        title = playlist.name
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
    }
    
    func fetchData() {
        DispatchQueue.global(qos: .userInitiated).async {
            ApiManger.shared.getPlaylistDetails(playlist: self.playlist) { result in
                switch result {
                case .success(let model):
                    print(model)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
