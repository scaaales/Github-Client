//
//  TintedImageView.swift
//  Github test
//
//  Created by Sergey Kletsov on 11/1/18.
//  Copyright © 2018 Sergey Kletsov. All rights reserved.
//

import UIKit

class TintedImageView: UIImageView {

	override func layoutSubviews() {
		super.layoutSubviews()
		let preferredTintColor = tintColor
		tintColor = nil
		tintColor = preferredTintColor
	}

}
