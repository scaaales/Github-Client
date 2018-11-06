//
//  HeaderView.swift
//  Github test
//
//  Created by Sergey Kletsov on 11/1/18.
//  Copyright © 2018 Sergey Kletsov. All rights reserved.
//

import UIKit

class HeaderView: UITableViewCell {
	static let reuseID = "header"
	
	@IBOutlet private weak var avatarImage: DownloadableImageView!
	@IBOutlet private weak var nameLabel: UILabel!
	@IBOutlet private weak var nicknameLabel: UILabel!
	@IBOutlet private weak var bioLabel: UILabel!
	@IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
	
	func setup(avatarImageURLString: String?,
					 name: String?,
					 nickname: String?,
					 bio: String?) {
		setImage(from: avatarImageURLString)
		nameLabel.text = name ?? "No name"
		nicknameLabel.text = nickname ?? "No nickname"
		bioLabel.text = bio ?? "No bio"
	}
	
	func setImage(from url: String?) {
		if let urlString = url {
			avatarImage.delegate = self
			avatarImage.setImage(urlString: urlString)
		}
		setupAvatarImageVIew()
	}
	
	private func setupAvatarImageVIew() {
		avatarImage.layer.cornerRadius = avatarImage.bounds.height / 2
		avatarImage.layer.borderWidth = 2
		avatarImage.layer.borderColor = UIColor.purple.cgColor
		avatarImage.clipsToBounds = true
		avatarImage.contentMode = .scaleAspectFit
	}
}

extension HeaderView: ImageDownloaderDelegate {
	func downloadStarted() {
		loadingIndicator.startAnimating()
	}
	
	func downloadFinnished() {
		loadingIndicator.stopAnimating()
	}
}
