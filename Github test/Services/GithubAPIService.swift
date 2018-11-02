//
//  GithubAPIService.swift
//  Github test
//
//  Created by Sergey Kletsov on 11/1/18.
//  Copyright © 2018 Sergey Kletsov. All rights reserved.
//

import Foundation

typealias JSON = [String: Any]

class GithubAPIService {
	
	enum GithubServiceError: Error {
		case noData
		
		var localizedDescription: String {
			switch self {
			case .noData:
				return "No data fouse in response"
			}
		}
	}
	
	private let httpClient: HTTPClient
	private let token: String
	
	init(token: String) {
		let githubApiURL = URL(string: .githubApiUrlString)!
		httpClient = HTTPClient(baseURL: githubApiURL)
		self.token = token
	}
	
	func getUser(completionHandler: @escaping ((User?, Error?) -> Void)) {
		let path = "/user"
		let header = ["Authorization": "token " + token]
		
		httpClient.makeRequest(path: path, method: nil, body: nil, queryItems: nil, headers: header) { data, error in
			DispatchQueue.main.async {
				if let error = error {
					completionHandler(nil, error)
					return
				}
				
				if let data = data {
					let jsonDecoder = JSONDecoder()
					do {
						let user = try jsonDecoder.decode(User.self, from: data)
						completionHandler(user, nil)
					} catch {
						completionHandler(nil, error)
					}
				} else {
					completionHandler(nil, GithubServiceError.noData)
				}
			}
		}
	}
	
	func updateUser(user: User, completionHandler: @escaping (Error?) -> Void) {
		let path = "/user"
		let header = ["Authorization": "token " + token]
		
		let parameters = [
			"name": user.name,
			"blog": user.blog,
			"company": user.company,
			"location": user.location,
			"bio": user.bio
		]
		
		guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { fatalError() }
		
		httpClient.makeRequest(path: path, method: .patch, body: httpBody, queryItems: nil, headers: header) { _, error in
			DispatchQueue.main.async {
				if let error = error {
					completionHandler(error)
				} else {
					completionHandler(nil)
				}
			}
		}
	}
	
}
