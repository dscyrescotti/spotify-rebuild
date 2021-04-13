//
//  FeaturePlaylistCell.swift
//  Spotify
//
//  Created by Dscyre Scotti on 13/04/2021.
//

import UIKit

class FeaturePlaylistCell: UICollectionViewCell, BrowseCell {
    static let identifier = "FeaturePlaylistCell"
    
    private let playlistCoverView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let playlistTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        return label
    }()
    
    private let creatorName: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 14, weight: .thin)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        return label
    }()
    
    struct Model {
        let id: String
        let name: String
        let artworkURL: URL?
        let creator: String
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            playlistCoverView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            playlistCoverView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            playlistCoverView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            playlistCoverView.heightAnchor.constraint(equalTo: widthAnchor, constant: 10),
            
            playlistTitle.topAnchor.constraint(equalTo: playlistCoverView.bottomAnchor, constant: 5),
            playlistTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            playlistTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            
            creatorName.topAnchor.constraint(equalTo: playlistTitle.bottomAnchor, constant: 5),
            creatorName.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            creatorName.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            creatorName.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -5)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playlistCoverView.image = nil
        playlistTitle.text = nil
        creatorName.text = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(playlistCoverView)
        addSubview(playlistTitle)
        addSubview(creatorName)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(model: Model) {
        playlistCoverView.sd_setImage(with: model.artworkURL)
        playlistTitle.text = model.name
        creatorName.text = model.creator
    }
}
