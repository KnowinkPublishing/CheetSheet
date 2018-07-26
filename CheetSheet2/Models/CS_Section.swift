//
//  CS_Section.swift
//  CheetSheet
//
//  Created by Steven Suranie on 4/8/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import Foundation
import RealmSwift

class CS_Section: Object {

    @objc dynamic var sectionID = UUID().uuidString
    @objc dynamic var sectionTitle = ""
}
