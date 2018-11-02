//
//  GithubService.swift
//  Github test
//
//  Created by Sergey Kletsov on 11/1/18.
//  Copyright © 2018 Sergey Kletsov. All rights reserved.
//

import Foundation
import AuthenticationServices

class GithubService {
	typealias CompletionHandler = (String?, Error?) -> Void
	
	enum GithubServiceError: Error {
		case codeChanged
		case noCode
		case noToken
		
		var localizedDescription: String {
			switch self {
			case .codeChanged:
				return "Code changed while authorizing"
			case .noCode:
				return "No code found in response"
			case .noToken:
				return "No token found in response"
			}
		}
	}
	
	private var authSession: ASWebAuthenticationSession?
	
	private let url: URL
	private let httpClient: HTTPClient
	private let state: String
	
	init() {
		state = UUID().uuidString
		url = URL(string: .githubUrlString)!
		httpClient = HTTPClient(baseURL: url)
	}
	
	private func authenticationURL() -> URL? {
		var urlComponnents = URLComponents(url: url, resolvingAgainstBaseURL: false)
		
		urlComponnents?.path = "/login/oauth/authorize"
		urlComponnents?.queryItems = generateQueryItems()
		
		return urlComponnents?.url
	}
	
	private func generateQueryItems() -> [URLQueryItem] {		
		let clientID = URLQueryItem(name: "client_id", value: .clientIDString)
		let state = URLQueryItem(name: "state", value: self.state)
		let redirectUri = URLQueryItem(name: "redirect_uri", value: .redirectUriString)
		let scopes = URLQueryItem(name: "scope", value: "user")
		
		return [clientID, state, redirectUri, scopes]
	}
	
	func authenticate(completionHandler: @escaping CompletionHandler) {
		DispatchQueue.global().async { [weak self] in
			guard let self = self else { return }
			
			guard let url = self.authenticationURL() else { return }
			
			self.authSession?.cancel()
			
			self.authSession = ASWebAuthenticationSession(url: url, callbackURLScheme: nil, completionHandler: { [unowned self] (newURL, error) in
				if let error = error {
					completionHandler(nil, error)
					return
				}
				
				guard let normalURL = newURL else {	return }
				
				let components = URLComponents(url: normalURL, resolvingAgainstBaseURL: false)
				guard let code = components?.queryItems?.first(where: { $0.name == "code" }),
					let state = components?.queryItems?.first(where: { $0.name == "state" }),
					let codeString = code.value,
					let stateString = state.value
					else {
						fatalError()
				}
				self.getAccessToken(code: codeString, state: stateString, completionHandler: completionHandler)
			})
			
			self.authSession?.start()
		}
	}
	
	private func getAccessToken(code: String, state: String, completionHandler: @escaping CompletionHandler) {
		guard state == self.state else {
			completionHandler(nil, GithubServiceError.codeChanged)
			return
		}
		
		let path = "/login/oauth/access_token"
		
		let parameters = [
			"client_id": String.clientIDString,
			"client_secret": .clientSecretString,
			"code": code
		]
		
		guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { fatalError() }
		
		let headers = [
			"Content-type": "application/json",
			"Accept": "application/json"
		]
		
		httpClient.makeRequest(path: path, method: .post, body: httpBody, queryItems: nil, headers: headers) { data, error in
			if let error = error {
				completionHandler(nil, error)
				return
			}
			if let data = data {
				do {
					let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
					guard let accessToken = (json as? [String: Any])?["access_token"] as? String else {
						completionHandler(nil, GithubServiceError.noToken)
						return
					}
						completionHandler(accessToken, nil)
				} catch {
					completionHandler(nil, error)
				}
			}
		}
		
	}
}
