//
//  AlbumTrackCell.swift
//  Spotify
//
//  Created by Dscyre Scotti on 14/04/2021.
//

import UIKit

class AlbumTrackCell: UICollectionViewCell, BrowseCell {
    static let identifier = "AlbumTrackCell"
    
    private let trackTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 22, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        return label
    }()
    
    private let artistName: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 17, weight: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        return label
    }()
    
    struct Model {
        let id: String
        let name: String
        let artist: String
        let artworkURL: URL?
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            trackTitle.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            trackTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            trackTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            artistName.topAnchor.constraint(equalTo: trackTitle.bottomAnchor, constant: 5),
            artistName.leadingAnchor.constraint(equalTo: trackTitle.leadingAnchor),
            artistName.trailingAnchor.constraint(equalTo: trackTitle.trailingAnchor),
            artistName.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        trackTitle.text = nil
        artistName.text = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondarySystemBackground
        addSubview(trackTitle)
        addSubview(artistName)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(model: Model) {
        trackTitle.text = model.name
        artistName.text = model.artist
    }
}

