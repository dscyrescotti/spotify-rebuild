//
//  LibraryToogleView.swift
//  Spotify
//
//  Created by Dscyre Scotti on 16/04/2021.
//

import UIKit

protocol LibraryToogleViewDelegate {
    func tappedPlaylistButton()
    func tappedAlbumButton()
    func updateNavigationItem()
}

class LibraryToogleView: UIView {
    
    enum State: Int {
        case playlist = 0
        case album = 1
    }
    
    var state: State = .playlist
    
    var indicatorCenterX: NSLayoutConstraint?
    var indicatorWidth: NSLayoutConstraint?
    
    var delegate: LibraryToogleViewDelegate?
    
    private let playlistButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.setTitle("Playlists", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let albumButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.secondaryLabel, for: .normal)
        button.setTitle("Albums", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        playlistButton.addTarget(self, action: #selector(tappedPlaylistButton), for: .touchUpInside)
        albumButton.addTarget(self, action: #selector(tappedAlbumButton), for: .touchUpInside)
        
        addSubview(playlistButton)
        addSubview(albumButton)
        addSubview(indicatorView)
        
        updateButtons(.playlist)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            playlistButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            playlistButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            albumButton.leadingAnchor.constraint(equalTo: playlistButton.trailingAnchor, constant: 20),
            albumButton.centerYAnchor.constraint(equalTo: playlistButton.centerYAnchor),
            
            indicatorView.heightAnchor.constraint(equalToConstant: 3),
            indicatorView.bottomAnchor.constraint(equalTo: playlistButton.bottomAnchor),
        ])
    }
    
    @objc func tappedPlaylistButton() {
        delegate?.tappedPlaylistButton()
        updateButtons(.playlist)
    }
    
    @objc func tappedAlbumButton() {
        delegate?.tappedAlbumButton()
        updateButtons(.album)
    }
    
    func updateButtons(_ state: State) {
        self.state = state
        delegate?.updateNavigationItem()
        update(state: state)
    }

    private func updateButton(_ selectedButton: UIButton, _ deselectedButton: UIButton) {
        deselectedButton.setTitleColor(.secondaryLabel, for: .normal)
        selectedButton.setTitleColor(.label, for: .normal)
    }
    
    func update(state: State) {
        remove()
        switch state {
        case .playlist:
            updateButton(playlistButton, albumButton)
            indicatorWidth = indicatorView.widthAnchor.constraint(equalTo: playlistButton.widthAnchor, multiplier: 1.2)
            indicatorCenterX = indicatorView.centerXAnchor.constraint(equalTo: playlistButton.centerXAnchor)
        case .album:
            updateButton(albumButton, playlistButton)
            indicatorWidth = indicatorView.widthAnchor.constraint(equalTo: albumButton.widthAnchor, multiplier: 1.2)
            indicatorCenterX = indicatorView.centerXAnchor.constraint(equalTo: albumButton.centerXAnchor)
        }
        if let c = indicatorWidth { addConstraint(c) }
        if let c = indicatorCenterX { addConstraint(c) }
        UIView.animate(withDuration: 0.2, animations: {
            self.layoutIfNeeded()
        })
    }
    
    func remove() {
        if let c = indicatorWidth { removeConstraint(c) }
        if let c = indicatorCenterX { removeConstraint(c) }
    }
}
