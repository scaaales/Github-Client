//
//  HTTPClient.swift
//  Github test
//
//  Created by Sergey Kletsov on 11/1/18.
//  Copyright © 2018 Sergey Kletsov. All rights reserved.
//

import Foundation

class HTTPClient {
	typealias CompletionHandler = (Data?, Error?) -> Void
	
	enum HTTPMethod: String {
		case get = "GET"
		case post = "POST"
		case patch = "PATCH"
	}
	
	enum NetworkError: Error {
		case urlNotValid
		case badStatusCode
		case noData
		
		var localizedDescription: String {
			switch self {
			case .urlNotValid:
				return "URL not valid"
			case .noData:
				return "Cannot extract data from response"
			case .badStatusCode:
				return "Respose status code not valid"
			}
		}
	}
	
	private let baseURL: URL
	
	init(baseURL: URL) {
		self.baseURL = baseURL
	}
	
	func makeRequest(path: String,
					 method: HTTPMethod?,
					 body: Data?,
					 queryItems: [URLQueryItem]?,
					 headers: [String: String]?,
					 completionHandler: @escaping CompletionHandler) {
		var urlComponnents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
		urlComponnents?.path = path
		urlComponnents?.queryItems = queryItems
		
		guard let url = urlComponnents?.url else {
			completionHandler(nil, NetworkError.urlNotValid)
			return
		}
		
		var requets = URLRequest(url: url)
		
		requets.httpMethod = method?.rawValue
		requets.httpBody = body
		if let headers = headers {
			for (key, value) in headers {
				requets.addValue(value, forHTTPHeaderField: key)
			}
		}
		
		URLSession.shared.dataTask(with: requets) { data, response, error in
			DispatchQueue.main.async {
				if let error = error {
					completionHandler(nil, error)
					return
				}
				
				if let response = response as? HTTPURLResponse {
					if (200..<300).contains(response.statusCode) {
						if let data = data {
							completionHandler(data, nil)
						} else {
							completionHandler(nil, NetworkError.noData)
						}
					} else {
						completionHandler(nil, NetworkError.badStatusCode)
					}
				}
			}
		}.resume()
	}
}
