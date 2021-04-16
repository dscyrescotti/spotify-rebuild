//
//  PlayerToolView.swift
//  Spotify
//
//  Created by Dscyre Scotti on 15/04/2021.
//

import Foundation
import UIKit

protocol PlayerToolViewDelegate {
    func clickPlayButton()
    func clickBackward()
    func clickForward()
    func sliderMove(value: Float)
}

class PlayerToolView: UIView {
    
    var delegate: PlayerToolViewDelegate?
    
    private var slider: UISlider = {
        let slider = UISlider()
        slider.tintColor = .systemGreen
        slider.setValue(0.5, animated: false)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private var title: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.numberOfLines = 1
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var subtitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.numberOfLines = 1
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40)), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        button.sizeToFit()
        return button
    }()
    
    private var backwardButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "backward.end.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        button.sizeToFit()
        return button
    }()
    
    private var forwardButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "forward.end.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        button.sizeToFit()
        return button
    }()
    
    private var noPreviewLabel: UILabel = {
        let label = UILabel()
        label.text = "Preview not available"
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        playButton.addTarget(self, action: #selector(tappedPlayButton), for: .touchUpInside)
        backwardButton.addTarget(self, action: #selector(tappedBackward), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(tappedForward), for: .touchUpInside)
        slider.addTarget(self, action: #selector(movedSlider), for: .valueChanged)
        
        addSubview(title)
        addSubview(subtitle)
        addSubview(slider)
        addSubview(playButton)
        addSubview(backwardButton)
        addSubview(forwardButton)
        addSubview(noPreviewLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            title.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10),
            subtitle.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            subtitle.trailingAnchor.constraint(equalTo: title.trailingAnchor),
            
            slider.widthAnchor.constraint(equalTo: widthAnchor, constant: -40),
            slider.centerXAnchor.constraint(equalTo: centerXAnchor),
            slider.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 10),
            
            playButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playButton.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 25),
            playButton.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -30),
            
            backwardButton.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
            backwardButton.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -35),
            
            forwardButton.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
            forwardButton.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 35),
            
            noPreviewLabel.leadingAnchor.constraint(equalTo: slider.leadingAnchor),
            noPreviewLabel.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 20),
            noPreviewLabel.trailingAnchor.constraint(equalTo: slider.trailingAnchor),
        ])
    }
    
    func configure(title: String?, subtitle: String?, hidesLabel: Bool) {
        self.title.text = title
        self.subtitle.text = subtitle
        self.noPreviewLabel.isHidden = hidesLabel
    }
    
    @objc func tappedPlayButton() {
        delegate?.clickPlayButton()
        if PlaybackManager.shared.isPlaying {
            playButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40)), for: .normal)
        } else {
            playButton.setImage(UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40)), for: .normal)
        }
    }
    
    @objc func tappedBackward() {
        delegate?.clickBackward()
    }
    
    @objc func tappedForward() {
        delegate?.clickForward()
    }
    
    @objc func movedSlider() {
        delegate?.sliderMove(value: slider.value)
    }
}
