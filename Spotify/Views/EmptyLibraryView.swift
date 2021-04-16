//
//  EmptyLibraryView.swift
//  Spotify
//
//  Created by Dscyre Scotti on 16/04/2021.
//

import UIKit

protocol EmptyLibraryViewDelegate {
    func tappedButton(_ view: EmptyLibraryView)
}

class EmptyLibraryView: UIView {
    
    var delegate: EmptyLibraryViewDelegate?
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 19, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        button.addTarget(self, action: #selector(tappedButton), for: .touchUpInside)
        
        addSubview(label)
        addSubview(button)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10),
            
            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }
    
    @objc func tappedButton() {
        delegate?.tappedButton(self)
    }
    
    func configure(text: String, buttonText: String) {
        self.label.text = text
        self.button.setTitle(buttonText, for: .normal)
    }
    
}
