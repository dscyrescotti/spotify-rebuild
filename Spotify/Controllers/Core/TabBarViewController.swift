//
//  TabBarViewController.swift
//  Spotify
//
//  Created by Dscyre Scotti on 11/04/2021.
//

import UIKit

class TabBarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
    }

}

extension TabBarViewController {
    func setUp() {
        let home = HomeViewController()
        let homeNav = UINavigationController(rootViewController: home)
        homeNav.tabBarItem = UITabBarItem(title: "Browse", image: UIImage(systemName: "house"), tag: 0)
        homeNav.navigationBar.tintColor = .label
        
        let search = SearchViewController()
        let searchNav = UINavigationController(rootViewController: search)
        searchNav.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        searchNav.navigationBar.tintColor = .label
        
        let library = LibraryViewController()
        let libraryNav = UINavigationController(rootViewController: library)
        libraryNav.tabBarItem = UITabBarItem(title: "Library", image: UIImage(systemName: "music.note.list"), tag: 2)
        libraryNav.navigationBar.tintColor = .label
        
        setViewControllers([homeNav, searchNav, libraryNav], animated: false)
    }
}
