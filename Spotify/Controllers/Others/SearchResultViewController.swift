//
//  SearchResultViewController.swift
//  Spotify
//
//  Created by Dscyre Scotti on 11/04/2021.
//

import UIKit

protocol SearchResultViewControllerDelegate {
    func pushController(_ viewController: UIViewController)
}

class SearchResultViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var sections: [SearchSection] = []
    var delegate: SearchResultViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
    }
    
    enum SearchSection {
        case artists([Artist])
        case albums([Album])
        case playlists([Playlist])
        case tracks([AudioTrack])
    }
}

extension SearchResultViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sections[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        sections[indexPath.section].generateCell(collectionView, indexPath: indexPath)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        sections[indexPath.section].clickCell(indexPath: indexPath, parentViewController: self) { [weak self] vc in
            self?.delegate?.pushController(vc)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: BrowseSectionTitleView.identifier, for: indexPath) as? BrowseSectionTitleView else { fatalError("BrowseSectionTitleView is not found.") }
        header.configure(title: sections[indexPath.section].title)
        return header
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        collectionView.isHidden = true
        collectionView.setContentOffset(.init(x: 0, y: -view.safeAreaInsets.top), animated: false)
    }
    
    
}

extension SearchResultViewController {
    func setUp() {
        view.backgroundColor = .systemBackground
        title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        
        let layout = UICollectionViewCompositionalLayout { [weak self] (index, _) -> NSCollectionLayoutSection? in
            self?.sections[index].createLayoutSection
        }
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(NewReleaseCell.self, forCellWithReuseIdentifier: NewReleaseCell.identifier)
        collectionView.register(FeaturePlaylistCell.self, forCellWithReuseIdentifier: FeaturePlaylistCell.identifier)
        collectionView.register(PlaylistTrackCell.self, forCellWithReuseIdentifier: PlaylistTrackCell.identifier)
        collectionView.register(ArtistCell.self, forCellWithReuseIdentifier: ArtistCell.identifier)
        collectionView.register(BrowseSectionTitleView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BrowseSectionTitleView.identifier)
        collectionView.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    func updateSections(_ model: Search) {
        sections.removeAll()
        sections.append(.artists(model.artists.items))
        sections.append(.albums(model.albums.items))
        sections.append(.playlists(model.playlists.items))
        sections.append(.tracks(model.tracks.items))
        collectionView.isHidden = false
        collectionView.reloadData()
    }
}

extension SearchResultViewController.SearchSection {
    var createLayoutSection: NSCollectionLayoutSection {
        
        let supplementaryItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        switch self {
        case .artists:
            return artistLayout([supplementaryItem])
        case .albums:
            return albumLayout([supplementaryItem])
        case .playlists:
            return playlistLayout([supplementaryItem])
        case .tracks:
            return trackLayout([supplementaryItem])
        }
    }
    
    private func artistLayout(_ boundarySupplementrayItems: [NSCollectionLayoutBoundarySupplementaryItem]) -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 2, bottom: 2, trailing: 2)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(170), heightDimension: .absolute(190)), subitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.boundarySupplementaryItems = boundarySupplementrayItems
        return section
    }
    
    private func albumLayout(_ boundarySupplementrayItems: [NSCollectionLayoutBoundarySupplementaryItem]) -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 2, bottom: 2, trailing: 2)

        let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)), subitem: item, count: 3)
        let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(390)), subitem: verticalGroup, count: 1)
        horizontalGroup.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        
        let section = NSCollectionLayoutSection(group: horizontalGroup)
        section.orthogonalScrollingBehavior = .groupPaging
        section.boundarySupplementaryItems = boundarySupplementrayItems
        return section
    }
    
    private func playlistLayout(_ boundarySupplementrayItems: [NSCollectionLayoutBoundarySupplementaryItem]) -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)), subitem: item, count: 2)
        let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .absolute(200), heightDimension: .absolute(540)), subitem: verticalGroup, count: 1)
        
        let section = NSCollectionLayoutSection(group: horizontalGroup)
        section.orthogonalScrollingBehavior = .continuous
        section.boundarySupplementaryItems = boundarySupplementrayItems
        return section
    }
    
    private func trackLayout(_ boundarySupplementrayItems: [NSCollectionLayoutBoundarySupplementaryItem]) -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80)), subitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2)
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = boundarySupplementrayItems
        return section
    }
    
    var count: Int {
        switch self {
        case .artists(let models):
            return models.count
        case .albums(let models):
            return models.count
        case .playlists(let models):
            return models.count
        case .tracks(let models):
            return models.count
        }
    }
    
    func generateCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        switch self {
        case .artists(let models):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArtistCell.identifier, for: indexPath) as? ArtistCell else { fatalError("ArtistCell is not found.") }
            cell.configure(model: models[indexPath.item].model)
            return cell
        case .albums(let models):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewReleaseCell.identifier, for: indexPath) as? NewReleaseCell else { fatalError("NewReleaseCell is not found.") }
            cell.configure(model: models[indexPath.item].model)
            return cell
        case .playlists(let models):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturePlaylistCell.identifier, for: indexPath) as? FeaturePlaylistCell else { fatalError("FeaturePlaylistCell is not found.") }
            cell.configure(model: models[indexPath.item].model)
            return cell
        case .tracks(let models):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistTrackCell.identifier, for: indexPath) as? PlaylistTrackCell else { fatalError("PlaylistTrackCell is not found.") }
            cell.configure(model: models[indexPath.item].model)
            return cell
        }
    }
    
    func clickCell(indexPath: IndexPath, parentViewController: UIViewController, pushViewController: @escaping (UIViewController) -> Void) {
        switch self {
        case .artists(_):
            break
        case .albums(let models):
            let vc = AlbumViewController(album: models[indexPath.item])
            pushViewController(vc)
        case .playlists(let models):
            let vc = PlaylistViewController(playlist: models[indexPath.item])
            pushViewController(vc)
        case .tracks(let models):
            PlaybackManager.shared.startPlayback(parentViewController, track: models[indexPath.item])
        }
    }
    
    var title: String {
        switch self {
        case .artists:
            return "Artists"
        case .albums:
            return "Albums"
        case .playlists:
            return "Playlists"
        case .tracks:
            return "Tracks"
        }
    }
    
    
}
