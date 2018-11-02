//
//  RoundedLabel.swift
//  Github test
//
//  Created by Sergey Kletsov on 11/1/18.
//  Copyright © 2018 Sergey Kletsov. All rights reserved.
//

import UIKit

class RoundedLabel: UILabel {	
	override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
		let textRect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
		return textRect.insetBy(dx: -6, dy: -2)
	}
	
	override func drawText(in rect: CGRect) {
		super.drawText(in: rect.insetBy(dx: 6, dy: 2))
		clipsToBounds = true
		layer.cornerRadius = frame.height / 2
	}

}
