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


}

extension HomeViewController {
    func setUp() {
        view.backgroundColor = .systemBackground
        title = "Home"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
