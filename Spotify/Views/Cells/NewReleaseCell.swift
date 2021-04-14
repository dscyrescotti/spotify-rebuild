//
//  NewReleaseCell.swift
//  Spotify
//
//  Created by Dscyre Scotti on 13/04/2021.
//

import UIKit
import SDWebImage

class NewReleaseCell: UICollectionViewCell, BrowseCell {
    static let identifier = "NewReleaseCell"
    
    private let albumCoverView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let albumTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        return label
    }()
    
    private let artistName: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 19, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        return label
    }()
    
    private let trackNumber: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        return label
    }()
    
    struct Model {
        let id: String
        let name: String
        let artworkURL: URL?
        let totalTracks: Int
        let artistName: String
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            albumCoverView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            albumCoverView.widthAnchor.constraint(equalToConstant: height - 10),
            albumCoverView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            albumCoverView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            
            albumTitle.topAnchor.constraint(equalTo: albumCoverView.topAnchor),
            albumTitle.leadingAnchor.constraint(equalTo: albumCoverView.trailingAnchor, constant: 10),
            albumTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            
            artistName.topAnchor.constraint(equalTo: albumTitle.bottomAnchor, constant: 5),
            artistName.leadingAnchor.constraint(equalTo: albumTitle.leadingAnchor),
            
            trackNumber.bottomAnchor.constraint(equalTo: albumCoverView.bottomAnchor),
            trackNumber.leadingAnchor.constraint(equalTo: albumTitle.leadingAnchor),
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        albumCoverView.image = nil
        albumTitle.text = nil
        artistName.text = nil
        trackNumber.text = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondarySystemBackground
        addSubview(albumCoverView)
        addSubview(albumTitle)
        addSubview(artistName)
        addSubview(trackNumber)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(model: Model) {
        albumCoverView.sd_setImage(with: model.artworkURL)
        albumTitle.text = model.name
        artistName.text = model.artistName
        trackNumber.text = "\(model.totalTracks) \(model.totalTracks == 1 ? "Track" : "Tracks")"
    }
}
