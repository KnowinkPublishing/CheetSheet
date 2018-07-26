//
//  StringExtension.swift
//  CheetSheet2
//
//  Created by Steven Suranie on 5/25/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)

        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)

        return ceil(boundingBox.width)
    }

    func stripSuffix(strSuffixToStrip: String) -> String {

        let arrSlices = self.components(separatedBy: strSuffixToStrip)
        if arrSlices.count > 0 {
            return arrSlices.first!
        }

        return self
    }

    func stripPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }

    func isNumeric() -> Bool {
        return Double(self) != nil
    }

    func capitalizeFirstWordOfSentence(_ sentence: String) -> String {

        let indexStartOfText = sentence.index(sentence.startIndex, offsetBy: 1)
        let endOfSentence = String(sentence[indexStartOfText...])

        return String(sentence.first!).uppercased() + endOfSentence
    }
}
