//
//  PlaylistsViewController.swift
//  Spotify
//
//  Created by Dscyre Scotti on 14/04/2021.
//

import UIKit

class PlaylistsViewController: UIViewController {
    
    var category: CategoryItem
    
    init(category: CategoryItem) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var playlists: [Playlist] = []
    private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchData()
        setUp()
    }
    
}

extension PlaylistsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        playlists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturePlaylistCell.identifier, for: indexPath) as? FeaturePlaylistCell else { fatalError("FeaturePlaylistCell is not found.") }
        cell.configure(model: playlists[indexPath.item].model)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let vc = PlaylistViewController(playlist: playlists[indexPath.item])
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

extension PlaylistsViewController {
    func setUp() {
        view.backgroundColor = .systemBackground
        title = category.name
        navigationItem.largeTitleDisplayMode = .never
        
        let layout = UICollectionViewCompositionalLayout { (_, _) -> NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            let isLandscape = self.view.width > self.view.height
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: isLandscape ? .absolute(320) : .absolute(260)), subitem: item, count: isLandscape ? 3 : 2)
            
            let section = NSCollectionLayoutSection(group: group)
            return section
        }
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(FeaturePlaylistCell.self, forCellWithReuseIdentifier: FeaturePlaylistCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    func fetchData() {
        ApiManger.shared.getCategoryPlaylists(id: category.id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    self?.playlists = model.playlists.items
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
