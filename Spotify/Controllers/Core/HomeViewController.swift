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
        let spinner = UIActivityIndicatorView(style: .medium)
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
        sections[indexPath.section].clickCell(indexPath: indexPath) { [weak self] vc in
            self?.navigationController?.pushViewController(vc, animated: true)
        }
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
        collectionView.register(RecommendationCell.self, forCellWithReuseIdentifier: RecommendationCell.identifier)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        view.addSubview(spinner)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func fetchData() {
        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()
        var newRelease: HomeSection?
        var featurePlaylist: HomeSection?
        var recommendation: HomeSection?
        
        DispatchQueue.global(qos: .userInitiated).async {
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
        }
        DispatchQueue.global(qos: .userInitiated).async {
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
        }
        DispatchQueue.global(qos: .userInitiated).async {
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
            self.collectionView.reloadData()
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        spinner.center = view.center
    }
}


extension HomeViewController.HomeSection {
    var createLayoutSection: NSCollectionLayoutSection {
        switch self {
        case .newRelease:
            return newReleaseLayout()
        case .featurePlaylist:
            return featurePlaylistLayout()
        case .recommendations:
            return recommendatinosLayout()
        }
    }
    
    private func newReleaseLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

        let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)), subitem: item, count: 3)
        let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(390)), subitem: verticalGroup, count: 1)
        
        let section = NSCollectionLayoutSection(group: horizontalGroup)
        section.orthogonalScrollingBehavior = .groupPaging
        return section
    }
    
    private func featurePlaylistLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)), subitem: item, count: 2)
        let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .absolute(200), heightDimension: .absolute(540)), subitem: verticalGroup, count: 1)
        
        let section = NSCollectionLayoutSection(group: horizontalGroup)
        section.orthogonalScrollingBehavior = .continuous
        return section
    }
    
    private func recommendatinosLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80)), subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
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
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendationCell.identifier, for: indexPath) as? RecommendationCell else { fatalError("RecommendationCell is not found.") }
            cell.configure(model: models[indexPath.item].model)
            return cell
        }
    }
    
    func clickCell(indexPath: IndexPath, pushViewController: @escaping (UIViewController) -> Void) {
        switch self {
        case .newRelease(let models):
            let vc = AlbumViewController(album: models[indexPath.item])
            pushViewController(vc)
        case .featurePlaylist(let models):
            let vc = PlaylistViewController(playlist: models[indexPath.item])
            pushViewController(vc)
        case .recommendations(_):
            break
        }
    }
}
