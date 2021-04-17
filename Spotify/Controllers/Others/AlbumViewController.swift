//
//  AlbumViewController.swift
//  Spotify
//
//  Created by Dscyre Scotti on 13/04/2021.
//

import UIKit

class AlbumViewController: UIViewController {
    
    private let album: Album
    private var tracks: [AudioTrack] = []
    private var collectionView: UICollectionView!
    
    private var saved: Bool?
    
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
        title = album.name
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        
        let layout = UICollectionViewCompositionalLayout { (index, _) -> NSCollectionLayoutSection? in
            self.playlistTrackLayout()
        }
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(AlbumTrackCell.self, forCellWithReuseIdentifier: AlbumTrackCell.identifier)
        collectionView.register(PlaylistHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PlaylistHeaderView.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(tappedShareButton))]
        
        addGesture()
    }
    
    func fetchData() {
        DispatchQueue.global(qos: .userInitiated).async {
            ApiManger.shared.getAlbumDetails(album: self.album) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let model):
                        self?.tracks = model.audioTracks
                        self?.collectionView.reloadData()
                        ApiManger.shared.getSavedAlbum(id: model.id) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success(let data):
                                    self?.saved = data.first
                                    self?.updateNavItem()
                                case .failure(let error):
                                    print(error)
                                }
                            }
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
    
    func updateNavItem() {
        if let saved = saved {
            DispatchQueue.main.async {
                if saved {
                    self.navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.tappedShareButton)), UIBarButtonItem(image: UIImage(systemName: "heart.fill"), style: .plain, target: self, action: #selector(self.tappedFavorite))]
                } else {
                    self.navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.tappedShareButton)), UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: #selector(self.tappedFavorite))]
                }
            }
        }
    }
    
    @objc func tappedFavorite() {
        guard let saved = saved else { return }
        if saved {
            ApiManger.shared.unsaveAlbum(id: album.id) { [weak self] success in
                if success {
                    NotificationCenter.default.post(name: .ablumNotification, object: nil)
                    self?.saved = !saved
                    self?.updateNavItem()
                }
            }
        } else {
            ApiManger.shared.saveAlbum(id: album.id) { [weak self] success in
                if success {
                    NotificationCenter.default.post(name: .ablumNotification, object: nil)
                    self?.saved = !saved
                    self?.updateNavItem()
                }
            }
        }
    }
}


extension AlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tracks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumTrackCell.identifier, for: indexPath) as? AlbumTrackCell else { fatalError("AlbumTrackCell is not found") }
        cell.configure(model: tracks[indexPath.item].albumTrack)
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PlaylistHeaderView.identifier, for: indexPath) as? PlaylistHeaderView else { fatalError("PlaylistHeaderView is not found.") }
        header.configure(model: album.headerModel)
        header.playButton.addTarget(self, action: #selector(tappedPlayButton), for: .touchUpInside)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        PlaybackManager.shared.startPlayback(self, track: tracks[indexPath.item], tracks: tracks)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    @objc func tappedPlayButton() {
        PlaybackManager.shared.startPlayback(self, track: tracks.first, tracks: tracks)
    }
    
    @objc func tappedShareButton() {
        guard let url = URL(string: album.externalUrls.spotify) else { return }
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
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
    
    func addGesture() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressGesture))
        collectionView.isUserInteractionEnabled = true
        collectionView.addGestureRecognizer(gesture)
    }
    
    @objc func longPressGesture(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        let location = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: location) else { return }
        let model = tracks[indexPath.item]
        let sheet = UIAlertController(title: model.name, message: "Do you want to add this to a playlist?", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
            let vc = MePlaylistController()
            vc.setAudioTrack(track: model)
            vc.delegate = self
            let nav = UINavigationController(rootViewController: vc)
            self?.present(nav, animated: true)
        }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }
}

extension AlbumViewController: MePlaylistControllerDelegate {
    func didChoosePlaylist(_ controller: MePlaylistController, track: AudioTrack, playlist: Playlist) {
        ApiManger.shared.addTrackToPlaylist(track: track, playlist: playlist) { _ in }
    }
}
