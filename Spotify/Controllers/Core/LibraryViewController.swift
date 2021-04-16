//
//  LibraryViewController.swift
//  Spotify
//
//  Created by Dscyre Scotti on 11/04/2021.
//

import UIKit

class LibraryViewController: UIViewController {
    
    private var pageViewController: UIPageViewController!
    private let playlistViewController = LibraryPlaylistViewController()
    private let albumViewController = LibraryAlbumViewController()
    
    private var controllers: [UIViewController] = []
    
    private let toggleView: LibraryToogleView = {
        let view = LibraryToogleView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
    }

}

extension LibraryViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = controllers.firstIndex(of: viewController) {
            if index > 0 {
                return controllers[index - 1]
            } else {
                return nil
            }
        }

        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = controllers.firstIndex(of: viewController) {
            if index < controllers.count - 1 {
                return controllers[index + 1]
            } else {
                return nil
            }
        }

        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let next = pageViewController.viewControllers?.first, let index = controllers.firstIndex(of: next), let state = LibraryToogleView.State.init(rawValue: index) {
            if completed {
                toggleView.updateButtons(state)
            } else {
                if let current = LibraryToogleView.State.init(rawValue: index) {
                    toggleView.updateButtons(current)
                }
            }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {

        if let next = pendingViewControllers.first, let index = controllers.firstIndex(of: next), let state = LibraryToogleView.State.init(rawValue: index) {
            toggleView.updateButtons(state)
        }
    }
}

extension LibraryViewController: LibraryToogleViewDelegate {
    func tappedPlaylistButton() {
        pageViewController.setViewControllers([controllers[0]], direction: .reverse, animated: true)
    }
    
    func tappedAlbumButton() {
        pageViewController.setViewControllers([controllers[1]], direction: .forward, animated: true)
    }
}

extension LibraryViewController {
    func setUp() {
        view.backgroundColor = .systemBackground
        title = "Library"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        controllers = [playlistViewController, albumViewController]
        
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.setViewControllers([controllers[0]], direction: .forward, animated: true)
        
        toggleView.delegate = self
        view.addSubview(toggleView)
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(tappedPlaylistNavigationItem))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        NSLayoutConstraint.activate([
            toggleView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            toggleView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            toggleView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            toggleView.heightAnchor.constraint(equalToConstant: 20),
            toggleView.bottomAnchor.constraint(equalTo: pageViewController.view.topAnchor, constant: -10),
            
            pageViewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    @objc func tappedPlaylistNavigationItem() {
        playlistViewController.showAlert()
    }
    
    func updateNavigationItem() {
        switch toggleView.state {
        case .playlist:
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(tappedPlaylistNavigationItem))
        case .album:
            navigationItem.rightBarButtonItem = nil
        }
    }
}
