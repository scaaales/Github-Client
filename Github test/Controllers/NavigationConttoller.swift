//
//  NavigationConttoller.swift
//  Github test
//
//  Created by Sergey Kletsov on 11/2/18.
//  Copyright © 2018 Sergey Kletsov. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if let token = UserDefaults.standard.string(forKey: .authTokenKey),
			let profileVC = storyboard?.instantiateViewController(withIdentifier: .profileIdentifier) as? ProfileViewController {
			profileVC.token = token
			viewControllers = [profileVC]
		} else {
			guard let authVC = storyboard?.instantiateViewController(withIdentifier: .authenticationIdentifier) else { return }
			viewControllers = [authVC]
		}
	}
	
	func showAuth() {
		if let authVC = viewControllers.first(where: { $0 is AuthenticationViewController }) {
			popToViewController(authVC, animated: true)
		} else {
			guard let authVC = storyboard?.instantiateViewController(withIdentifier: .authenticationIdentifier) else { return }
			viewControllers.insert(authVC, at: 0)
			popViewController(animated: true)
		}
	}
}
