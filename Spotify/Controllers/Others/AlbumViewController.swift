//
//  AlbumViewController.swift
//  Spotify
//
//  Created by Dscyre Scotti on 13/04/2021.
//

import UIKit

class AlbumViewController: UIViewController {
    
    private let album: Album
    
    init(album: Album) {
        self.album = album
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

extension AlbumViewController {
    func setUp() {
        view.backgroundColor = .systemBackground
        title = album.name
        navigationItem.largeTitleDisplayMode = .never
    }
    
    func fetchData() {
        DispatchQueue.global(qos: .userInitiated).async {
            ApiManger.shared.getAlbumDetails(album: self.album) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let model):
                        print(model)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}
