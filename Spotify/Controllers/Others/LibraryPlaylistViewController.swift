//
//  LibraryPlaylistViewController.swift
//  Spotify
//
//  Created by Dscyre Scotti on 16/04/2021.
//

import UIKit

class LibraryPlaylistViewController: UIViewController {
    
    private var playlists: [Playlist] = []
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(LibraryCell.self, forCellReuseIdentifier: LibraryCell.identifier)
        return tableView
    }()
    
    private let emptyView: EmptyLibraryView = {
        let view = EmptyLibraryView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.configure(text: "You don't have any playlist yet. Create a new playlist.", buttonText: "Create")
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchData()
        setUp()
    }
}

extension LibraryPlaylistViewController: EmptyLibraryViewDelegate {
    func tappedButton(_ view: EmptyLibraryView) {
        showAlert()
    }
}

extension LibraryPlaylistViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LibraryCell.identifier, for: indexPath) as? LibraryCell else { fatalError("LibraryCell is not found.") }
        cell.configure(model: playlists[indexPath.row].libraryModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = PlaylistViewController(playlist: playlists[indexPath.item])
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension LibraryPlaylistViewController {
    func setUp() {
        view.backgroundColor = .systemBackground
        
        emptyView.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        view.addSubview(emptyView)
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
        ApiManger.shared.getUserPlaylist { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    self?.playlists = model.items
                    self?.updateUI()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func updateUI() {
        if playlists.isEmpty {
            emptyView.isHidden = false
        } else {
            emptyView.isHidden = true
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
    
    func showAlert() {
        let alert = UIAlertController(title: "Enter playlist name", message: nil, preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = "Name"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { [weak self] _ in
            guard let text = alert.textFields?.first?.text, !text.isEmpty else { return }
            self?.createPlaylist(name: text)
        }))
        present(alert, animated: true)
    }
}
