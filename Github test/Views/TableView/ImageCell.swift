//
//  ImageCell.swift
//  Github test
//
//  Created by Sergey Kletsov on 11/1/18.
//  Copyright © 2018 Sergey Kletsov. All rights reserved.
//

import UIKit

protocol ConfiguratableCell {
	static var reuseID: String { get }
	func setup(with cellContent: CellContent)
}

class ImageCell: UITableViewCell, ConfiguratableCell {
	static let reuseID = "imageCell"
	
	@IBOutlet private weak var iconImage: UIImageView!
	@IBOutlet private weak var mainTextLabel: UILabel!
	
	func setTextColor(color: UIColor) {
		mainTextLabel.textColor = color
	}
	
	func setup(with cellContent: CellContent) {
		self.iconImage.image = cellContent.icon
		mainTextLabel.text = cellContent.text
	}
}
