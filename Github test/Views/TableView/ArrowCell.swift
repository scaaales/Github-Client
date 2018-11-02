//
//  ArrowCell.swift
//  Github test
//
//  Created by Sergey Kletsov on 11/1/18.
//  Copyright © 2018 Sergey Kletsov. All rights reserved.
//

import UIKit

class ArrowCell: UITableViewCell, ConfiguratableCell {
	static let reuseID = "arrowCell"
	
	@IBOutlet private weak var mainTextLabel: UILabel!
	@IBOutlet private weak var roundedBadgeLabel: RoundedLabel!
	
	func setup(with cellContent: CellContent) {
		mainTextLabel.text = cellContent.text
		if let badgeText = cellContent.detailText {
			roundedBadgeLabel?.text = badgeText
			roundedBadgeLabel?.layer.backgroundColor = UIColor.normalPurple.cgColor
		} else {
			roundedBadgeLabel?.removeFromSuperview()
		}
	}
	
}
