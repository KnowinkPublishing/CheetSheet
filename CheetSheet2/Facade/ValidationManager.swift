//
//  ValidationManager.swift
//  CheatSheet
//
//  Created by Steven Suranie on 11/17/17.
//  Copyright © 2017 Steven Suranie. All rights reserved.
//

import Foundation
import UIKit

struct ValidationManager {

    //credit StitchFix team for writing this - http://multithreaded.stitchfix.com/blog/2016/11/02/email-validation-swift/

    func validateEmail(field: UITextField) -> Dictionary<String, Any> {

        var dictEmailData: Dictionary<String, Any> = [:]

        guard let trimmedText = field.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {

            dictEmailData["Valid"] = false
            dictEmailData["EmailAddress"] = field.text
            return dictEmailData
        }

        guard let dataDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            dictEmailData["Valid"] = false
            dictEmailData["EmailAddress"] = field.text
            return dictEmailData
        }

        let range = NSRange(location: 0, length: NSString(string: trimmedText).length)
        let allMatches = dataDetector.matches(in: trimmedText,
                                              options: [],
                                              range: range)

        if allMatches.count == 1,
            allMatches.first?.url?.absoluteString.contains("mailto:") == true {
            dictEmailData["Valid"] = true
            dictEmailData["EmailAddress"] = field.text
            return dictEmailData
        }

        dictEmailData["Valid"] = false
        dictEmailData["EmailAddress"] = field.text
        return dictEmailData
    }
}
