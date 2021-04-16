//
//  LibraryCell.swift
//  Spotify
//
//  Created by Dscyre Scotti on 16/04/2021.
//

import UIKit

class LibraryCell: UITableViewCell, BrowseCell {
    static var identifier: String = "LibraryCell"
    
    private let playlistCoverView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondaryLabel
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
            playlistCoverView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            playlistCoverView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            playlistCoverView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            playlistCoverView.widthAnchor.constraint(equalToConstant: 70),
            
            playlistTitle.leadingAnchor.constraint(equalTo: playlistCoverView.trailingAnchor, constant: 15),
            playlistTitle.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            playlistTitle.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            
            creatorName.leadingAnchor.constraint(equalTo: playlistTitle.leadingAnchor),
            creatorName.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            creatorName.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -15)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playlistCoverView.image = nil
        playlistTitle.text = nil
        creatorName.text = nil
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
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
