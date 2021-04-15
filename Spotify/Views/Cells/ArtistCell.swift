//
//  ArtistCell.swift
//  Spotify
//
//  Created by Dscyre Scotti on 15/04/2021.
//

import UIKit

class ArtistCell: UICollectionViewCell, BrowseCell {
    static let identifier = "ArtistCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let artistName: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.sizeToFit()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.layer.cornerRadius = width / 2
        imageView.layer.masksToBounds = true
        addSubview(imageView)
        addSubview(artistName)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: widthAnchor),
            
            artistName.leadingAnchor.constraint(equalTo: leadingAnchor),
            artistName.trailingAnchor.constraint(equalTo: trailingAnchor),
            artistName.bottomAnchor.constraint(equalTo: bottomAnchor),
            artistName.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        artistName.text = nil
    }
    
    func configure(model: Model) {
        imageView.sd_setImage(with: model.imageURL)
        artistName.text = model.name
    }
    
    struct Model {
        let id: String
        let name: String
        let imageURL: URL?
    }
}
