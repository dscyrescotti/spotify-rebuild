//
//  HomeViewController.swift
//  Spotify
//
//  Created by Dscyre Scotti on 11/04/2021.
//

import UIKit

class HomeViewController: UIViewController {
    
    private var sections = [HomeSection]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var collectionView: UICollectionView!
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        return spinner
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchData()
        setUp()
    }

    @objc func tappedSettings() {
        let vc = SettingViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    enum HomeSection {
        case newRelease([Album])
        case featurePlaylist([Playlist])
        case recommendations([AudioTrack])
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
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
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: BrowseSectionTitleView.identifier, for: indexPath) as? BrowseSectionTitleView else { fatalError("BrowseSectionTitleView is not found.") }
        header.configure(title: sections[indexPath.section].title)
        return header
    }
}

extension HomeViewController {
    func setUp() {
        view.backgroundColor = .systemBackground
        title = "Browse"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(tappedSettings))
        
        
        let layout = UICollectionViewCompositionalLayout { [weak self] (index, _) -> NSCollectionLayoutSection? in
            self?.sections[index].createLayoutSection
        }
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(NewReleaseCell.self, forCellWithReuseIdentifier: NewReleaseCell.identifier)
        collectionView.register(FeaturePlaylistCell.self, forCellWithReuseIdentifier: FeaturePlaylistCell.identifier)
        collectionView.register(PlaylistTrackCell.self, forCellWithReuseIdentifier: PlaylistTrackCell.identifier)
        collectionView.register(BrowseSectionTitleView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BrowseSectionTitleView.identifier)
        collectionView.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        view.addSubview(spinner)
        spinner.startAnimating()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        addGesture()
    }
    
    func fetchData() {
        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()
        var newRelease: HomeSection?
        var featurePlaylist: HomeSection?
        var recommendation: HomeSection?
        ApiManger.shared.getAllNewReleases { result in
            DispatchQueue.main.async {
                defer { group.leave() }
                switch result {
                case .success(let model):
                    newRelease = .newRelease(model.albums.items)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        ApiManger.shared.getFeaturePlaylists { result in
            DispatchQueue.main.async {
                defer { group.leave() }
                switch result {
                case .success(let model):
                    featurePlaylist = .featurePlaylist(model.playlists.items)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        ApiManger.shared.getRecommendedGenres { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    let genres = Set(model.genres.shuffled()[0...4])
                    DispatchQueue.global(qos: .userInitiated).async {
                        ApiManger.shared.getRecommendations(genres: genres) { result in
                            DispatchQueue.main.async {
                                defer { group.leave() }
                                switch result {
                                case .success(let model):
                                    recommendation = .recommendations(model.tracks)
                                case .failure(let error):
                                    print(error.localizedDescription)
                                }
                            }
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        group.notify(queue: .main) {
            if let newRelease = newRelease {
                self.sections.append(newRelease)
            }
            if let featurePlaylist = featurePlaylist {
                self.sections.append(featurePlaylist)
            }
            if let recommendation = recommendation {
                self.sections.append(recommendation)
            }
            self.spinner.stopAnimating()
            self.collectionView.reloadData()
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        spinner.center = view.center
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
        switch sections[indexPath.section] {
        case .recommendations(let models):
            let model = models[indexPath.item]
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
        default:
            break
        }
    }
    
}

extension HomeViewController.HomeSection {
    var createLayoutSection: NSCollectionLayoutSection {
        
        let supplementaryItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        switch self {
        case .newRelease:
            return newReleaseLayout([supplementaryItem])
        case .featurePlaylist:
            return featurePlaylistLayout([supplementaryItem])
        case .recommendations:
            return recommendatinosLayout([supplementaryItem])
        }
    }
    
    private func newReleaseLayout(_ boundarySupplementrayItems: [NSCollectionLayoutBoundarySupplementaryItem]) -> NSCollectionLayoutSection {
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
    
    private func featurePlaylistLayout(_ boundarySupplementrayItems: [NSCollectionLayoutBoundarySupplementaryItem]) -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)), subitem: item, count: 2)
        let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .absolute(200), heightDimension: .absolute(540)), subitem: verticalGroup, count: 1)
        
        let section = NSCollectionLayoutSection(group: horizontalGroup)
        section.orthogonalScrollingBehavior = .continuous
        section.boundarySupplementaryItems = boundarySupplementrayItems
        return section
    }
    
    private func recommendatinosLayout(_ boundarySupplementrayItems: [NSCollectionLayoutBoundarySupplementaryItem]) -> NSCollectionLayoutSection {
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
        case .newRelease(let models):
            return models.count
        case .featurePlaylist(let models):
            return models.count
        case .recommendations(let models):
            return models.count
        }
    }
    
    func generateCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        switch self {
        case .newRelease(let models):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewReleaseCell.identifier, for: indexPath) as? NewReleaseCell else { fatalError("NewReleaseCell is not found.") }
            cell.configure(model: models[indexPath.item].model)
            return cell
        case .featurePlaylist(let models):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturePlaylistCell.identifier, for: indexPath) as? FeaturePlaylistCell else { fatalError("FeaturePlaylistCell is not found.") }
            cell.configure(model: models[indexPath.item].model)
            return cell
        case .recommendations(let models):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistTrackCell.identifier, for: indexPath) as? PlaylistTrackCell else { fatalError("PlaylistTrackCell is not found.") }
            cell.configure(model: models[indexPath.item].model)
            return cell
        }
    }
    
    func clickCell(indexPath: IndexPath, parentViewController: UIViewController, pushViewController: @escaping (UIViewController) -> Void) {
        switch self {
        case .newRelease(let models):
            let vc = AlbumViewController(album: models[indexPath.item])
            pushViewController(vc)
        case .featurePlaylist(let models):
            let vc = PlaylistViewController(playlist: models[indexPath.item])
            pushViewController(vc)
        case .recommendations(let models):
            PlaybackManager.shared.startPlayback(parentViewController, track: models[indexPath.item], tracks: models)
        break 
        }
    }
    
    var title: String {
        switch self {
        case .newRelease:
            return "New Releases"
        case .featurePlaylist:
            return "Feature Playlists"
        case .recommendations:
            return "Recommendations"
        }
    }
}

extension HomeViewController: MePlaylistControllerDelegate {
    func didChoosePlaylist(_ controller: MePlaylistController, track: AudioTrack, playlist: Playlist) {
        ApiManger.shared.addTrackToPlaylist(track: track, playlist: playlist) { _ in }
    }
}
