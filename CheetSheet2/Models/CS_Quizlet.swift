//
//  CS_Quizlet.swift
//  CheetSheet2
//
//  Created by Steven Suranie on 5/26/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import Foundation
import RealmSwift

class CS_Quizlet: Object {

    @objc dynamic var quizletID = ""
    @objc dynamic var quizletTitle = ""
    @objc dynamic var quizletDescription = ""
    @objc dynamic var quizletCreatedBy = ""
    @objc dynamic var quizletCreatedDate = ""
    @objc dynamic var quizletModifiedDate = ""
    @objc dynamic var quizletTermCount = ""
    @objc dynamic var quizletURL = ""

}
