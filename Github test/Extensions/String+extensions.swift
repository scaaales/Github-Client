//
//  String+extensions.swift
//  Github test
//
//  Created by Sergey Kletsov on 10/31/18.
//  Copyright © 2018 Sergey Kletsov. All rights reserved.
//

import Foundation

extension String {
	static let authTokenKey = "AuthToken"
	
	// - MARK: Storyboard
	static let showProfileSegue = "showProfile"
	
	static let profileNavigationIdentifier = "profileNavigation"
	static let authenticationIdentifier = "authentication"
	static let profileIdentifier = "profile"
	
	// - MARK: Network
	static let githubUrlString = "https://github.com/"
	static let githubApiUrlString = "https://api.github.com/"
	
	static let redirectUriString = "githubClient://authorization"
	
	static let clientSecretString = "632da1d55dd3f6ab047c8abf82c1157f58be8bde"
	static let clientIDString = "adbddbf693347eebaa7e"
	
	// - MARK: Methods
	var isURL: Bool {
		let urlRegEx = "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
		
		let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
		return urlTest.evaluate(with: self)
	}
	
	var isEmail: Bool {
		let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
		
		let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
		return emailTest.evaluate(with: self)
	}
}
