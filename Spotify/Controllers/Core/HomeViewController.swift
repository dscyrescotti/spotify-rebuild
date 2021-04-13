//
//  HomeViewController.swift
//  Spotify
//
//  Created by Dscyre Scotti on 11/04/2021.
//

import UIKit

class HomeViewController: UIViewController {
    
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, _) -> NSCollectionLayoutSection? in
            HomeLayout.init(rawValue: sectionIndex)?.createLayoutSection
        }
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }()
    
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
    
    enum HomeLayout: Int {
        case newRelease = 0
        case featurePlaylist = 1
        case recommendations = 2
    }

}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .red
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        3
    }
}

extension HomeViewController {
    func setUp() {
        view.backgroundColor = .systemBackground
        title = "Browse"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(tappedSettings))
        
        view.addSubview(collectionView)
        view.addSubview(spinner)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func fetchData() {
        DispatchQueue.global(qos: .userInitiated).async {
            ApiManger.shared.getRecommendedGenres { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let model):
                        let genres = Set(model.genres.shuffled()[0...4])
                        DispatchQueue.global(qos: .userInitiated).async {
                            ApiManger.shared.getRecommendations(genres: genres) { result in
                                print(result)
                            }
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        spinner.center = view.center
    }
}


extension HomeViewController.HomeLayout {
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
        let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .absolute(200), heightDimension: .absolute(400)), subitem: verticalGroup, count: 1)
        
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
    
}
