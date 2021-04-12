//
//  WelcomeViewController.swift
//  Spotify
//
//  Created by Dscyre Scotti on 11/04/2021.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    private let signInButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBackground
        button.setTitle("Sign In with Spotify", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
    }
    
    @objc func tapped() {
        let vc = AuthViewController()
        vc.completionHandler = { [weak self] success in
            self?.handleSignIn(success)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func handleSignIn(_ success: Bool) {
        guard success else {
            let alert = UIAlertController(title: "Oops", message: "Unable to sign in. Please try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
            present(alert, animated: true)
            return
        }
        let main = TabBarViewController()
        main.modalPresentationStyle = .fullScreen
        present(main, animated: true)
    }
}

extension WelcomeViewController {
    func setUp() {
        title = "Spotify"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemGreen
        view.addSubview(signInButton)
        signInButton.addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        signInButton.frame = CGRect(x: 20, y: view.bottom - 50 - view.safeAreaInsets.bottom, width: view.width - 40, height: 50)
    }
}
