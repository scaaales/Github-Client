//
//  ProfileViewController.swift
//  Github test
//
//  Created by Sergey Kletsov on 10/29/18.
//  Copyright © 2018 Sergey Kletsov. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
	
	@IBOutlet private weak var tableView: UITableView!
	@IBOutlet private weak var tabBar: UITabBar!
	@IBOutlet private weak var blurredView: UIView!
	@IBOutlet private weak var profileLoadingIndicator: UIActivityIndicatorView!
	@IBOutlet private weak var editButton: UIBarButtonItem!
	@IBOutlet private weak var logoutButton: UIBarButtonItem!
	
	var user: User? {
		didSet {
			if let user = user {
				dataSource = UserDataSource(user: user)
			}
		}
	}
	var token: String!
	
	private var dataSource: UserDataSource?
	
	var githubAPIService: GithubAPIService!
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		githubAPIService = GithubAPIService(token: token)
		loadUser()
		setupTableView()
		setupTabBar()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.navigationBar.isHidden = false
		tableView.reloadData()
	}
	
	private func setupTableView() {
		tableView.delegate = self
		tableView.dataSource = self
		tableView.sectionHeaderHeight = UITableView.automaticDimension
		tableView.estimatedSectionHeaderHeight = 2
		tableView.rowHeight = 44
		tableView.sectionFooterHeight = UITableView.automaticDimension
		tableView.estimatedSectionFooterHeight = 2
		tableView.backgroundColor = .clear
	}
	
	private func loadUser() {
		startAnimatingIndicators()
		
		githubAPIService.getUser { [weak self] user, error in
			if let error = error as? HTTPClient.NetworkError {
				if error == .badStatusCode {
					(self?.navigationController as? NavigationController)?.showAuth()
				}
			}
			
			if let user = user {
				self?.user = user
				self?.stopAnimatingIndicators()
				self?.tableView.reloadData()
			}
		}
	}

	private func setupTabBar() {
		tabBar.selectedItem = tabBar.items?[0]
		tabBar.unselectedItemTintColor = .darkPurple
	}
	
	@IBAction private func logout(_ sender: Any) {
		UserDefaults.standard.removeObject(forKey: .authTokenKey)
		(navigationController as? NavigationController)?.showAuth()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let editVC = segue.destination as? EditProfileViewController {
			editVC.user = user
			editVC.githubApiService = githubAPIService
		}
	}
}

extension ProfileViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: false)
		guard let dataSource = dataSource else { return }
		let currentText = dataSource.sections[indexPath.section][indexPath.row].text
		if currentText.isURL {
			guard let url = URL(string: currentText) else { return }
			UIApplication.shared.open(url)
		} else if currentText.isEmail {
			guard let url = URL(string: "mailto:\(currentText)") else { return }
			UIApplication.shared.open(url)
		}
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if section == 0, let user = user {
			let header = tableView.dequeueReusableCell(withIdentifier: HeaderView.reuseID) as? HeaderView
			
			header?.setup(avatarImageURLString: user.avatarUrl, name: user.name, nickname: user.login, bio: user.bio)
			
			return header?.contentView
		}
		return nil
	}
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		guard let dataSource = dataSource else { return nil }
		if section == dataSource.sections.count - 1 {
			return nil
		}
		let placeholderView = UIView()
		placeholderView.backgroundColor = .clear
		placeholderView.translatesAutoresizingMaskIntoConstraints = false
		placeholderView.heightAnchor.constraint(equalToConstant: 8).isActive = true
		return placeholderView
	}
	
}

extension ProfileViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return dataSource?.sections.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return dataSource?.sections[section].count ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let dataSource = dataSource else { fatalError() }
		if indexPath.section == dataSource.sections.count - 1 {
			let cell: ArrowCell = configure(at: indexPath)
			return cell
		} else {
			let cell: ImageCell = configure(at: indexPath)
			return cell
		}
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		guard let dataSource = dataSource else { return }
		guard let cell = cell as? ImageCell else { return }
		let currentText = dataSource.sections[indexPath.section][indexPath.row].text
		if currentText.isURL || currentText.isEmail {
			cell.setTextColor(color: .lightPurple)
		} else {
			cell.setTextColor(color: .darkPurple)
		}
	}
	
}

private extension ProfileViewController {
	func configure<T: ConfiguratableCell>(at indexPath: IndexPath) -> T where T: UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: T.reuseID, for: indexPath) as? T,
			let dataSource = dataSource else { fatalError() }
		let cellContent = dataSource.sections[indexPath.section][indexPath.row]
		cell.setup(with: cellContent)
		return cell
	}
	
	func startAnimatingIndicators() {
		blurredView.isHidden = false
		profileLoadingIndicator.startAnimating()
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		tabBar.items?.forEach({ $0.isEnabled = false })
		setUserInteraction(enabled: false)
	}
	
	func stopAnimatingIndicators() {
		blurredView.isHidden = true
		profileLoadingIndicator.stopAnimating()
		UIApplication.shared.isNetworkActivityIndicatorVisible = false
		setUserInteraction(enabled: true)
	}

	func setUserInteraction(enabled: Bool) {
		tabBar.items?.forEach({ $0.isEnabled = enabled })
		editButton.isEnabled = enabled
		logoutButton.isEnabled = enabled
	}
	
}
