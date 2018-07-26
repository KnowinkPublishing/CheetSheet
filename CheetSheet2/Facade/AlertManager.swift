//
//  AlertManager.swift
//  iOSInterviewCheatSheet
//
//  Created by Steven Suranie on 11/2/17.
//  Copyright © 2017 Steven Suranie. All rights reserved.
//

import Foundation
import UIKit

struct AlertManager {

    func presentAlert(_ title: String, _ message: String, _ presenter: UIViewController) {

        let myAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        myAlert.addAction(okAction)

        presenter.present(myAlert, animated: true, completion: nil)
    }

}
