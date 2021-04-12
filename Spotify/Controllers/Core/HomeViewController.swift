//
//  HomeViewController.swift
//  Spotify
//
//  Created by Dscyre Scotti on 11/04/2021.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchData()
        setUp()
    }

    @objc func tappedSettings() {
        let vc = SettingViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension HomeViewController {
    func setUp() {
        view.backgroundColor = .systemBackground
        title = "Browse"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(tappedSettings))
    }
    
    func fetchData() {
        DispatchQueue.global(qos: .userInitiated).async {
            ApiManger.shared.getRecommendedGenres { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let model):
                        let genres = Set(model.genres.shuffled()[0...4])
                        DispatchQueue.global(qos: .userInitiated).async {
                            ApiManger.shared.getRecommendations(genres: genres) { _ in }
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}
