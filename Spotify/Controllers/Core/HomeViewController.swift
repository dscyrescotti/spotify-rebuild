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
        title = "Home"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(tappedSettings))
    }
}
