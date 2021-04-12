//
//  LibraryViewController.swift
//  Spotify
//
//  Created by Dscyre Scotti on 11/04/2021.
//

import UIKit

class LibraryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
    }

}

extension LibraryViewController {
    func setUp() {
        view.backgroundColor = .systemBackground
        title = "Library"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
