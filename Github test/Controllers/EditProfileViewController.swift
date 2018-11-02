//
//  EditProfileViewController.swift
//  Github test
//
//  Created by Sergey Kletsov on 10/31/18.
//  Copyright © 2018 Sergey Kletsov. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {

	@IBOutlet private weak var saveButton: UIBarButtonItem!
	@IBOutlet private weak var cancelButton: UIBarButtonItem!
	@IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet private weak var blurredView: UIView!
	@IBOutlet private weak var tableView: UITableView!
	@IBOutlet private weak var tableViewBottomConstraint: NSLayoutConstraint!
	
	var user: User!
	var githubApiService: GithubAPIService!
	
	private var cells = [(name: String, value: (text: String, placeholder: String))]()
	
	override func viewDidLoad() {
        super.viewDidLoad()
		setupTableView()
		fillCells()
		view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
	}
	
	@IBAction func cancelTapped(_ sender: Any) {
		navigationController?.popViewController(animated: true)
	}
	
	@IBAction func saveTapped(_ sender: Any) {
		view.endEditing(true)
		cancelButton.isEnabled = false
		saveButton.isEnabled = false
		startAnimatingIndicators()
		user.name = cells.first(where: { $0.name == "Name" })?.value.text ?? user.name
		user.blog = cells.first(where: { $0.name == "Blog" })?.value.text ?? user.blog
		user.company = cells.first(where: { $0.name == "Company" })?.value.text ?? user.company
		user.location = cells.first(where: { $0.name == "Location" })?.value.text ?? user.location
		user.bio = cells.first(where: { $0.name == "Bio" })?.value.text ?? user.bio
		githubApiService.updateUser(user: user) { [weak self] error in
			if error == nil {
				self?.stopAnimatingIndicators()
				self?.cancelButton.isEnabled = true
				self?.saveButton.isEnabled = true
				guard let profileVC = self?.navigationController?.viewControllers.first(where: { $0 is ProfileViewController }) as? ProfileViewController,
					let user = self?.user else { return }
				profileVC.user = user
				self?.navigationController?.popViewController(animated: true)
			}
		}
	}
	
	@objc func keyboardWillChangeFrame(notification: Notification) {
		guard let userInfo = notification.userInfo else { return }
		let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
		let endFrameY = endFrame?.origin.y ?? 0
		let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
		let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
		let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
		let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)
		if endFrameY >= UIScreen.main.bounds.size.height {
			self.tableViewBottomConstraint.constant = 0
		} else {
			self.tableViewBottomConstraint.constant = endFrame?.size.height ?? 0
		}
		UIView.animate(withDuration: duration, delay: 0, options: animationCurve, animations: {
			self.view.layoutIfNeeded()
		})
	}
	
	@objc func tapped() {
		view.endEditing(true)
	}
	
}

extension EditProfileViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let header = tableView.dequeueReusableCell(withIdentifier: HeaderView.reuseID) as? HeaderView
		header?.setImage(from: user.avatarUrl)
		return header?.contentView
	}
}

extension EditProfileViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cells.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.row == cells.count - 1 {
			guard let bioCell = tableView.dequeueReusableCell(withIdentifier: BioCell.reuseID, for: indexPath) as? BioCell else { fatalError() }
			let content = cells[indexPath.row]
			bioCell.textView.text = content.value.text
			bioCell.textView.delegate = self
			bioCell.textView.restorationIdentifier = content.name
			return bioCell
		} else {
			guard let rightEditCell = tableView.dequeueReusableCell(withIdentifier: RightEditCell.reuseID, for: indexPath) as? RightEditCell else { fatalError() }
			let content = cells[indexPath.row]
			rightEditCell.titleLabel.text = content.name
			rightEditCell.detailTextField.restorationIdentifier = content.name
			rightEditCell.detailTextField.text = content.value.text
			rightEditCell.detailTextField.delegate = self
			rightEditCell.detailTextField.placeholder = content.value.placeholder
			return rightEditCell
		}
	}
}

extension EditProfileViewController: UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		UIView.setAnimationsEnabled(false)
		textView.sizeToFit()
		self.tableView.beginUpdates()
		self.tableView.endUpdates()
		UIView.setAnimationsEnabled(true)
		guard let editedIndex = cells.firstIndex(where: { $0.name == textView.restorationIdentifier }),
			let newText = textView.text else { return }
		cells[editedIndex].value.text = newText
	}
}

extension EditProfileViewController: UITextFieldDelegate {
	func textFieldDidEndEditing(_ textField: UITextField) {
		guard let editedIndex = cells.firstIndex(where: { $0.name == textField.restorationIdentifier }),
			let newText = textField.text else { return }
		cells[editedIndex].value.text = newText
	}
}

private extension EditProfileViewController {
	func startAnimatingIndicators() {
		blurredView.isHidden = false
		activityIndicator.startAnimating()
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
	}
	
	func stopAnimatingIndicators() {
		blurredView.isHidden = true
		activityIndicator.stopAnimating()
		UIApplication.shared.isNetworkActivityIndicatorVisible = false
	}
	
	private func setupTableView() {
		tableView.delegate = self
		tableView.dataSource = self
		tableView.sectionHeaderHeight = UITableView.automaticDimension
		tableView.estimatedSectionHeaderHeight = 100
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 44
		tableView.backgroundColor = .clear
	}
	
	private func fillCells() {
		let name = (name: "Name", (text: user.name, placeholder: "Name or nickname"))
		let blog = (name: "Blog", value:(text: user.blog ?? "", placeholder: "example.com"))
		let company = (name: "Company", value:(text: user.company ?? "", placeholder: "Company name"))
		let location = (name: "Location", value:(text: user.location ?? "", placeholder: "City"))
		let bio = (name: "Bio", value:(text: user.bio ?? "Enter bio here", placeholder: ""))
		
		cells = [name, blog, company, location, bio]
	}
}
