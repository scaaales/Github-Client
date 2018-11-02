//
//  DownloadableImageView.swift
//  Github test
//
//  Created by Sergey Kletsov on 11/1/18.
//  Copyright © 2018 Sergey Kletsov. All rights reserved.
//

import UIKit

private let imageCache = NSCache<AnyObject, AnyObject>()

protocol ImageDownloaderDelegate: class {
	func downloadStarted()
	func downloadFinnished()
}

class DownloadableImageView: UIImageView {

	weak var delegate: ImageDownloaderDelegate?

	func setImage(urlString: String) {
		guard let url = URL(string: urlString) else { return }
		
		image = nil
		
		if let imageFromCache = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
			self.image = imageFromCache
			return
		}
		
		delegate?.downloadStarted()
		
		URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
			DispatchQueue.main.async {
				self?.delegate?.downloadFinnished()
			}
			if let data = data {
				DispatchQueue.main.async {
					guard let imageToCache = UIImage(data: data) else { return }
					imageCache.setObject(imageToCache, forKey: urlString as AnyObject)
					self?.image = imageToCache
				}
			}
		}.resume()
	}
	
}
