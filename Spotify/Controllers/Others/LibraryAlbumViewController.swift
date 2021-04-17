//
//  LibraryAlbumViewController.swift
//  Spotify
//
//  Created by Dscyre Scotti on 16/04/2021.
//

import UIKit

class LibraryAlbumViewController: UIViewController {
    
    private var albums: [Album] = []
    private var observer: NSObjectProtocol?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(LibraryCell.self, forCellReuseIdentifier: LibraryCell.identifier)
        tableView.isHidden = true
        return tableView
    }()
    
    private let emptyView: EmptyLibraryView = {
        let view = EmptyLibraryView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.configure(text: "You don't have any ablum.", buttonText: "Browse")
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchData()
        setUp()
    }
}

extension LibraryAlbumViewController: EmptyLibraryViewDelegate {
    func tappedButton(_ view: EmptyLibraryView) {
        
    }
}

extension LibraryAlbumViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LibraryCell.identifier, for: indexPath) as? LibraryCell else { fatalError("LibraryCell is not found.") }
        cell.configure(model: albums[indexPath.row].libraryModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = AlbumViewController(album: albums[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension LibraryAlbumViewController {
    func setUp() {
        view.backgroundColor = .systemBackground
        
        emptyView.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        view.addSubview(emptyView)
        
        observer = NotificationCenter.default.addObserver(forName: .ablumNotification, object: nil, queue: .main, using: { [weak self] _ in
            self?.fetchData()
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        NSLayoutConstraint.activate([
            emptyView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        tableView.frame = view.bounds
    }
    
    func fetchData() {
        albums.removeAll()
        ApiManger.shared.getUserAlbums { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    self?.albums = model.items.map { $0.album }
                    self?.updateUI()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func updateUI() {
        if albums.isEmpty {
            emptyView.isHidden = false
            tableView.isHidden = true
        } else {
            emptyView.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
    
    func createPlaylist(name: String) {
        ApiManger.shared.createPlaylist(with: name) { [weak self] success in
            if success {
                self?.fetchData()
            }
        }
    }
}
