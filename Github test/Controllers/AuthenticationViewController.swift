//
//  AuthenticationViewController.swift
//  Github test
//
//  Created by Sergey Kletsov on 10/29/18.
//  Copyright © 2018 Sergey Kletsov. All rights reserved.
//

import UIKit

class AuthenticationViewController: UIViewController {

	@IBOutlet private weak var indicatorStackView: UIStackView!
	@IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet private weak var loginButton: UIButton!
	
	private let githubService = GithubService()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupButton()
	}
	
	private func setupButton() {
		loginButton.layer.cornerRadius = loginButton.bounds.height / 2
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.navigationBar.isHidden = true
	}
	
	func authenticate() {
		loginButton.isEnabled = false
		githubService.authenticate { [weak self] (token, error) in
			self?.stopAnimatingIndicators()
			self?.loginButton.isEnabled = true
			if let error = error {
				print(error.localizedDescription)
				return
			}
			
			if let token = token {
				UserDefaults.standard.set(token, forKey: .authTokenKey)
				self?.performSegue(withIdentifier: .showProfileSegue, sender: token)
			}
		}
	}
	
	
	@IBAction private func login(_ sender: Any) {
		startAnimatingIndicators()
		authenticate()
	}
	
	private func startAnimatingIndicators() {
		indicatorStackView.isHidden = false
		activityIndicator.startAnimating()
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
	}
	
	private func stopAnimatingIndicators() {
		activityIndicator.stopAnimating()
		UIApplication.shared.isNetworkActivityIndicatorVisible = false
		indicatorStackView.isHidden = true
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        // MARK: - Remark. I'm not sure about 'fatalError'. Maybe there is can be better way than fatalError
		guard let token = sender as? String,
			let profileVC = segue.destination as? ProfileViewController else { return }
		profileVC.token = token
	}
	
}
