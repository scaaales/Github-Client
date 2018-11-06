//
//  DataSource.swift
//  Github test
//
//  Created by Sergey Kletsov on 11/1/18.
//  Copyright © 2018 Sergey Kletsov. All rights reserved.
//

import UIKit

struct CellContent {
	let text: String
	let icon: UIImage?
	let detailText: String?
}

class UserDataSource {
	
	private let staticCells = [
		"Repositories",
		"Start",
		"Foolowers",
		"Following"
	]
	
	let sections: [[CellContent]]

	init(user: User) {
		var result = [[CellContent]]()
		
		if let firstSection = UserDataSource.createFirstSection(from: user) {
			result.append(firstSection)
		}
		
		let secondSection = [
			CellContent(text: "Repositories", icon: nil, detailText: "\(user.publicRepos ?? 0)"),
			CellContent(text: "Start", icon: nil, detailText: nil),
			CellContent(text: "Foolowers", icon: nil, detailText: nil),
			CellContent(text: "Following", icon: nil, detailText: nil)
		]
		
		result.append(secondSection)
		
		sections = result
	}
	
	private static func createFirstSection(from user: User) -> [CellContent]? {
		if user.email == nil, user.blog == nil, user.company == nil, user.location == nil {
			return nil
		}
		var result = [CellContent]()
		
		if let email = user.email {
			result.append(CellContent(text: email, icon: #imageLiteral(resourceName: "mail"), detailText: nil))
		}
		
		if let blog = user.blog {
			result.append(CellContent(text: blog, icon: #imageLiteral(resourceName: "browser"), detailText: nil))
		}
		
		if let company = user.company {
			result.append(CellContent(text: company, icon: #imageLiteral(resourceName: "company"), detailText: nil))
		}
		
		if let location = user.location {
			result.append(CellContent(text: location, icon: #imageLiteral(resourceName: "location"), detailText: nil))
		}
		
		return result
	}

}

