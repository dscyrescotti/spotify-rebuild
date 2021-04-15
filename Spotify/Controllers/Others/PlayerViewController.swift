//
//  PlayerViewController.swift
//  Spotify
//
//  Created by Dscyre Scotti on 11/04/2021.
//

import UIKit

class PlayerViewController: UIViewController {
    
    var imagePortraitTop: NSLayoutConstraint?
    var imagePortraitX: NSLayoutConstraint?
    var imagePortraitHeight: NSLayoutConstraint?
    var imagePortraitWidth: NSLayoutConstraint?
    
    var imageLandscapeLeading: NSLayoutConstraint?
    var imageLandscapeY: NSLayoutConstraint?
    var imageLandscapeHeight: NSLayoutConstraint?
    var imageLandscapeWidth: NSLayoutConstraint?
    
    private let trackImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpConstraints()
        setUp()
    }

}

extension PlayerViewController {
    func setUp() {
        view.backgroundColor = .systemBackground
        
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(tappedCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(tappedAction))
        
        view.addSubview(trackImageView)
        trackImageView.backgroundColor = .systemGreen
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let orientation = UIDevice.current.orientation
        if orientation == .portrait {
            self.applyPortraitConstraints()
        } else {
            self.applyLandscapeConstraints()
        }
    }
    
    func setUpConstraints() {
        imagePortraitTop = NSLayoutConstraint(item: trackImageView, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 20)
        imagePortraitX = NSLayoutConstraint(item: trackImageView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        imagePortraitWidth = NSLayoutConstraint(item: trackImageView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.8, constant: 0)
        imagePortraitHeight = NSLayoutConstraint(item: trackImageView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.8, constant: 0)
        
        imageLandscapeLeading = .init(item: trackImageView, attribute: .leading, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .leading, multiplier: 1, constant: 20)
        imageLandscapeY = .init(item: trackImageView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        imageLandscapeWidth = .init(item: trackImageView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0.8, constant: 0)
        imageLandscapeHeight = .init(item: trackImageView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0.8, constant: 0)
    }
    
    func removeConstraints() {
        if let c = imagePortraitTop { view.removeConstraint(c) }
        if let c = imagePortraitX { view.removeConstraint(c) }
        if let c = imagePortraitWidth { view.removeConstraint(c) }
        if let c = imagePortraitHeight { view.removeConstraint(c) }
        
        if let c = imageLandscapeHeight { view.removeConstraint(c) }
        if let c = imageLandscapeWidth { view.removeConstraint(c) }
        if let c = imageLandscapeY { view.removeConstraint(c) }
        if let c = imageLandscapeLeading { view.removeConstraint(c) }
    }
    
    func applyPortraitConstraints() {
        removeConstraints()
        view.addConstraint(imagePortraitTop!)
        view.addConstraint(imagePortraitX!)
        view.addConstraint(imagePortraitWidth!)
        view.addConstraint(imagePortraitHeight!)
    }
    
    func applyLandscapeConstraints() {
        removeConstraints()
        view.addConstraint(imageLandscapeHeight!)
        view.addConstraint(imageLandscapeWidth!)
        view.addConstraint(imageLandscapeY!)
        view.addConstraint(imageLandscapeLeading!)
    }
    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        coordinator.animate { _ in
//            let orientation = UIDevice.current.orientation
//            if orientation == .portrait {
//                self.applyPortraitConstraints()
//            } else {
//                self.applyLandscapeConstraints()
//            }
//        }
//        super.viewWillTransition(to: size, with: coordinator)
//    }
    
    @objc func tappedCancel() {
        dismiss(animated: true)
    }
    
    @objc func tappedAction() {
        
    }
}
