//
//  ProfileViewController.swift
//  Spotify
//
//  Created by Dscyre Scotti on 11/04/2021.
//

import UIKit
import SDWebImage

class ProfileViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.isHidden = true
        return tableView
    }()
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Failed to load your profile"
        label.textColor = .secondaryLabel
        label.sizeToFit()
        label.isHidden = true
        return label
    }()
    
    var rows: [UserProfile.Row] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchUserProfile()
        setUp()
    }

}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let row = rows[indexPath.row]
        cell.textLabel?.text = row.data
        cell.selectionStyle = .none
        return cell
    }
}

extension ProfileViewController {
    func setUp() {
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        title = "Profile"
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(label)
    }
    
    func fetchUserProfile() {
        DispatchQueue.global(qos: .userInitiated).async {
            ApiManger.shared.getCurrentUserProfile { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let profile):
                        self?.updateRow(profile: profile)
                    case .failure(let error):
                        print(error.localizedDescription)
                        self?.promptFailure()
                    }
                }
            }
        }
    }
    
    func updateRow(profile: UserProfile) {
        createTableViewHeader(with: profile.images.first?.url)
        rows.append(contentsOf: profile.toRows)
        tableView.isHidden = false
        tableView.reloadData()
    }
    
    func promptFailure() {
        tableView.isHidden = true
        label.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        label.center = view.center
    }
    
    func createTableViewHeader(with url: String?) {
        guard let string = url, let url = URL(string: string) else { return }
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.width / 1.5))
        let imageSize = headerView.height / 2
        let imageView = UIImageView(frame: .init(x: 0, y: 0, width: imageSize, height: imageSize))
        headerView.addSubview(imageView)
        imageView.center = headerView.center
        imageView.sd_setImage(with: url)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageSize / 2
        imageView.backgroundColor = .secondaryLabel
        tableView.tableHeaderView = headerView
    }
}
