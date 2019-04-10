//
//  LogNavigationViewController.swift
//  exampleWindow
//
//  Created by Remi Robert on 20/01/2017.
//  Copyright © 2017 Remi Robert. All rights reserved.
//

import UIKit

class LogNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.tintColor = Color.mainGreen
        navigationBar.titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary([NSAttributedString.Key.font.rawValue: UIFont.boldSystemFont(ofSize: 20),
                                             NSAttributedString.Key.foregroundColor.rawValue: Color.mainGreen])

        let selector = #selector(LogNavigationViewController.exit)

        let image = UIImage(named: "close", in: Bundle(for: LogNavigationViewController.self), compatibleWith: nil)
        let leftButton = UIBarButtonItem(image: image,
                                         style: .done, target: self, action: selector)
        topViewController?.navigationItem.leftBarButtonItem = leftButton
    }

    @objc func exit() {
        dismiss(animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
