//
//  User.swift
//  Github test
//
//  Created by Sergey Kletsov on 10/29/18.
//  Copyright © 2018 Sergey Kletsov. All rights reserved.
//

struct User: Codable {
	var name: String
	let login: String
	var bio: String?
	let avatarUrl: String
	let email: String?
	var location: String?
	var company: String?
	let publicRepos: Int
	var blog: String?
	
	enum CodingKeys: String, CodingKey {
		case name, login, bio, email, location, company, blog
		case avatarUrl = "avatar_url"
		case publicRepos = "public_repos"
	}
}
