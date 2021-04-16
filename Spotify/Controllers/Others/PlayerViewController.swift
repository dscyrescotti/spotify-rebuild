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
    var toolPortraitTop: NSLayoutConstraint?
    var toolPortraitBottom: NSLayoutConstraint?
    var toolPortraitWidth: NSLayoutConstraint?
    
    var imageLandscapeLeading: NSLayoutConstraint?
    var imageLandscapeY: NSLayoutConstraint?
    var imageLandscapeHeight: NSLayoutConstraint?
    var imageLandscapeWidth: NSLayoutConstraint?
    var toolLandscapeLeading: NSLayoutConstraint?
    var toolLandscapeTrailing: NSLayoutConstraint?
    var toolLandscapeY: NSLayoutConstraint?
    
    private let trackImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let playerToolView: PlayerToolView = {
        let view = PlayerToolView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpConstraints()
        setUp()
    }
    
    struct Model {
        let url: URL?
        let title: String
        let subtitle: String
        let hidesLabel: Bool
    }
    
    func configure(model: Model?) {
        title = model?.title
        playerToolView.configure(title: model?.title, subtitle: model?.subtitle, hidesLabel: model?.hidesLabel ?? true)
        trackImageView.sd_setImage(with: model?.url)
    }
}

extension PlayerViewController {
    func setUp() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = .label
        
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(tappedCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(tappedAction))
        
        playerToolView.delegate = self
        PlaybackManager.shared.delegate = self
        view.addSubview(trackImageView)
        view.addSubview(playerToolView)
        trackImageView.backgroundColor = .systemBackground
    }
    
    @objc func tappedCancel() {
        dismiss(animated: true)
    }
    
    @objc func tappedAction() {
        
    }
}

extension PlayerViewController {
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if view.isLandscape {
            self.applyLandscapeConstraints()
        } else {
            self.applyPortraitConstraints()
        }
    }
    
    func setUpConstraints() {
        imagePortraitTop = trackImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100)
        imagePortraitX = trackImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        imagePortraitWidth = trackImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9)
        imagePortraitHeight = trackImageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9)
        
        toolPortraitTop = playerToolView.topAnchor.constraint(equalTo: trackImageView.bottomAnchor, constant: 20)
        toolPortraitBottom = playerToolView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        toolPortraitWidth = playerToolView.widthAnchor.constraint(equalTo: view.widthAnchor)
        
        imageLandscapeLeading = trackImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
        imageLandscapeY = trackImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        imageLandscapeWidth = trackImageView.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8)
        imageLandscapeHeight = trackImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8)
        
        toolLandscapeY = playerToolView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        toolLandscapeLeading = playerToolView.leadingAnchor.constraint(equalTo: trackImageView.trailingAnchor, constant: 20)
        toolLandscapeTrailing = playerToolView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
    }
    
    func removeConstraints() {
        if let c = imagePortraitTop { view.removeConstraint(c) }
        if let c = imagePortraitX { view.removeConstraint(c) }
        if let c = imagePortraitWidth { view.removeConstraint(c) }
        if let c = imagePortraitHeight { view.removeConstraint(c) }
        
        if let c = toolPortraitWidth { view.removeConstraint(c) }
        if let c = toolPortraitBottom { view.removeConstraint(c) }
        if let c = toolPortraitTop { view.removeConstraint(c) }
        
        if let c = imageLandscapeHeight { view.removeConstraint(c) }
        if let c = imageLandscapeWidth { view.removeConstraint(c) }
        if let c = imageLandscapeY { view.removeConstraint(c) }
        if let c = imageLandscapeLeading { view.removeConstraint(c) }
        
        
        if let c = toolLandscapeTrailing { view.removeConstraint(c) }
        if let c = toolLandscapeLeading { view.removeConstraint(c) }
        if let c = toolLandscapeY { view.removeConstraint(c) }
    }
    
    func applyPortraitConstraints() {
        removeConstraints()
        view.addConstraint(imagePortraitTop!)
        view.addConstraint(imagePortraitX!)
        view.addConstraint(imagePortraitWidth!)
        view.addConstraint(imagePortraitHeight!)
        
        view.addConstraint(toolPortraitWidth!)
        view.addConstraint(toolPortraitBottom!)
        view.addConstraint(toolPortraitTop!)
    }
    
    func applyLandscapeConstraints() {
        removeConstraints()
        view.addConstraint(imageLandscapeHeight!)
        view.addConstraint(imageLandscapeWidth!)
        view.addConstraint(imageLandscapeY!)
        view.addConstraint(imageLandscapeLeading!)
        
        view.addConstraint(toolLandscapeTrailing!)
        view.addConstraint(toolLandscapeLeading!)
        view.addConstraint(toolLandscapeY!)
    }
}

extension PlayerViewController: PlaybackManagerDelegate {
    func moveToNextTrack() {
        PlaybackManager.shared.configure(completion: configure)
    }
}

extension PlayerViewController: PlayerToolViewDelegate {
    func clickPlayButton() {
        PlaybackManager.shared.play()
    }
    
    func clickBackward() {
        PlaybackManager.shared.backward()
        PlaybackManager.shared.configure(completion: configure)
    }
    
    func clickForward() {
        PlaybackManager.shared.forward()
        PlaybackManager.shared.configure(completion: configure)
    }
    
    func sliderMove(value: Float) {
        PlaybackManager.shared.changeVolume(value: value)
    }
}
