//
//  MePlaylistController.swift
//  Spotify
//
//  Created by Dscyre Scotti on 17/04/2021.
//

import UIKit

protocol MePlaylistControllerDelegate {
    func didChoosePlaylist(_ controller: MePlaylistController, track: AudioTrack, playlist: Playlist)
}

class MePlaylistController: UIViewController {
    
    private var selectedTrack: AudioTrack?
    private var playlists: [Playlist] = []
    var delegate: MePlaylistControllerDelegate?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(LibraryCell.self, forCellReuseIdentifier: LibraryCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchData()
        setUp()
    }
}

extension MePlaylistController: UITableViewDelegate, UITableViewDataSource {
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
        if let track = selectedTrack {
            delegate?.didChoosePlaylist(self, track: track, playlist: playlists[indexPath.item])
        }
        dismiss(animated: true)
    }
}

extension MePlaylistController {
    func setUp() {
        view.backgroundColor = .systemBackground
        
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        navigationController?.navigationBar.tintColor = .label
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showAlert))
        title = "Choose a playlist"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    func fetchData() {
        ApiManger.shared.getMePlaylist { [weak self] result in
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
        tableView.reloadData()
    }
    
    func createPlaylist(name: String) {
        ApiManger.shared.createPlaylist(with: name) { [weak self] success in
            if success {
                self?.fetchData()
            }
        }
    }
    
    @objc func showAlert() {
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
    
    func setAudioTrack(track: AudioTrack) {
        self.selectedTrack = track
    }
}
