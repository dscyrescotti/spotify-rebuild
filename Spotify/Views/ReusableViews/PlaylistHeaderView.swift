//
//  PlaylistHeaderView.swift
//  Spotify
//
//  Created by Dscyre Scotti on 14/04/2021.
//

import UIKit
import SDWebImage

class PlaylistHeaderView: UICollectionReusableView {
    static let identifier = "PlaylistHeaderView"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let playlistName: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }()
    
    let playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let ownerName: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 1
        label.textColor = .secondaryLabel
        label.sizeToFit()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        addSubview(imageView)
        addSubview(playlistName)
        addSubview(playButton)
        addSubview(descriptionLabel)
        addSubview(ownerName)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageSize = height * 0.6
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            imageView.widthAnchor.constraint(equalToConstant: imageSize),
            imageView.heightAnchor.constraint(equalToConstant: imageSize),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            playlistName.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            playlistName.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
            playlistName.widthAnchor.constraint(equalToConstant: width - 10),
            
            playButton.centerXAnchor.constraint(equalTo: playlistName.centerXAnchor),
            playButton.topAnchor.constraint(equalTo: playlistName.bottomAnchor, constant: 10),
            playButton.heightAnchor.constraint(equalToConstant: 30),
            playButton.widthAnchor.constraint(equalToConstant: 100),
            
            descriptionLabel.centerXAnchor.constraint(equalTo: playButton.centerXAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            ownerName.centerXAnchor.constraint(equalTo: descriptionLabel.centerXAnchor),
            ownerName.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 5),
            ownerName.widthAnchor.constraint(equalToConstant: width - 10),
            ownerName.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -10)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        playlistName.text = nil
        ownerName.text = nil
        descriptionLabel.text = nil
    }
    
    func configure(model: Model) {
        imageView.sd_setImage(with: model.artworkURL)
        playlistName.text = model.name
        ownerName.text = model.owner
        descriptionLabel.text = model.description
    }
    
    struct Model {
        let name: String
        let owner: String
        let description: String
        let artworkURL: URL?
    }
}
