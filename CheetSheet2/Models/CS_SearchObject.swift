//
//  SearchObject.swift
//  CheetSheet2
//
//  Created by Steven Suranie on 7/1/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import Foundation
import RealmSwift

enum ResourceSourceType: String {
    case khanResource = "Khan Academy"
    case quizletResource = "Quizlet"
    case pbslmResource = "PBS Media Learning"
    case dictionaryResource = "Merriam Webster"
    case locResource = "Library of Congress"
}

enum ResourceSequeType: String {

    case khanSegue = "toKhanFromHistory"
    case quizletSegue = "toQuizletFromHistory"
    case pbslmSegue = "toPBSFromHistory"
    case dictionarySegue = "toMerriamFromHistory"
    case locSegue = "toLOCFromHistory"
}

class CheetSheetSearch: Object {

    @objc dynamic var strTerms = ""
    @objc dynamic var strJSON = ""
    @objc dynamic var xmlResult = ""
    @objc dynamic var dtSearch = Date()
    @objc dynamic var resourceType = ""
    @objc dynamic var segueType = ""
    @objc dynamic var grade = ""

    var strImageName: String {

        if let thisResourceType = ResourceSourceType(rawValue: self.resourceType) {

            switch thisResourceType {

                case .khanResource:
                    return "khan"

                case .quizletResource:
                    return "quizlet"

                case .pbslmResource:
                    return "pbslm"

                case .dictionaryResource:
                    return "dictionary"

                case .locResource:
                    return "loc"
            }
        }

        return ""
    }

}
