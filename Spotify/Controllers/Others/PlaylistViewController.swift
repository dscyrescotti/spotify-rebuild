//
//  PlaylistViewController.swift
//  Spotify
//
//  Created by Dscyre Scotti on 11/04/2021.
//

import UIKit

class PlaylistViewController: UIViewController {
    
    private let playlist: Playlist
    private var editable: Bool = false
    
    private var collectionView: UICollectionView!
    private var tracks: [AudioTrack] = []
    
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
        cell.configure(model: tracks[indexPath.item].model)
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
        addGesture()
    }
    
    func fetchData() {
        DispatchQueue.global(qos: .userInitiated).async {
            ApiManger.shared.getPlaylistDetails(playlist: self.playlist) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let model):
                        self?.tracks = model.tracks.items.map { $0.track }
                        self?.editable = model.collaborative
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        PlaybackManager.shared.startPlayback(self, track: tracks[indexPath.item], tracks: tracks)
    }
    
    @objc func tappedPlayButton() {
        PlaybackManager.shared.startPlayback(self, track: tracks.first, tracks: tracks)
    }
    
    @objc func tappedShareButton() {
        guard let url = URL(string: playlist.externalUrls.spotify) else { return }
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
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
        sheet.addAction(UIAlertAction(title: "Remove", style: .default, handler: { [weak self] _ in
            self?.deleteTrack(track: model, indexPath: indexPath)
        }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }
    
    func deleteTrack(track: AudioTrack, indexPath: IndexPath) {
        ApiManger.shared.removeTrackFromPlaylist(track: track, playlist: playlist) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.tracks.remove(at: indexPath.item)
                    self?.collectionView.deleteItems(at: [indexPath])
                }
            }
        }
    }
}

extension PlaylistViewController: MePlaylistControllerDelegate {
    func didChoosePlaylist(_ controller: MePlaylistController, track: AudioTrack, playlist: Playlist) {
        ApiManger.shared.addTrackToPlaylist(track: track, playlist: playlist) { _ in }
    }
}

