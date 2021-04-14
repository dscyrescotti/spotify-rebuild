//
//  PlaylistViewController.swift
//  Spotify
//
//  Created by Dscyre Scotti on 11/04/2021.
//

import UIKit

class PlaylistViewController: UIViewController {
    
    private let playlist: Playlist
    
    private var collectionView: UICollectionView!
    private var tracks: [PlaylistTrackItem] = []
    
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

extension PlaylistViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tracks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistTrackCell.identifier, for: indexPath) as? PlaylistTrackCell else { fatalError("PlaylistTrackCell is not found") }
        cell.configure(model: tracks[indexPath.item].track.model)
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PlaylistHeaderView.identifier, for: indexPath) as? PlaylistHeaderView else { fatalError("PlaylistHeaderView is not found.") }
        header.configure(model: playlist.headerModel)
        header.playButton.addTarget(self, action: #selector(tappedPlayButton), for: .touchUpInside)
        return header
    }
}

extension PlaylistViewController {
    func setUp() {
        title = playlist.name
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        
        let layout = UICollectionViewCompositionalLayout { (index, _) -> NSCollectionLayoutSection? in
            self.playlistTrackLayout()
        }
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(PlaylistTrackCell.self, forCellWithReuseIdentifier: PlaylistTrackCell.identifier)
        collectionView.register(PlaylistHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PlaylistHeaderView.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(tappedShareButton))
    }
    
    func fetchData() {
        DispatchQueue.global(qos: .userInitiated).async {
            ApiManger.shared.getPlaylistDetails(playlist: self.playlist) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let model):
                        self?.tracks = model.tracks.items
                        self?.collectionView.reloadData()
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
    
    private func playlistTrackLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80)), subitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2)
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(min(view.width, view.height))), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        ]
        return section
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    @objc func tappedPlayButton() {
        print("play all")
    }
    
    @objc func tappedShareButton() {
        guard let url = URL(string: playlist.externalUrls.spotify) else { return }
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
}
