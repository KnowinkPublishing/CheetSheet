//
//  CS_Resource.swift
//  CheetSheet2
//
//  Created by Steven Suranie on 5/23/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import Foundation
import RealmSwift

class CS_Resource: Object {

    @objc dynamic var resourceID = UUID().uuidString
    @objc dynamic var resourceName = ""
    @objc dynamic var resourceType = ""
    @objc dynamic var resourceBaseURL = ""

}
