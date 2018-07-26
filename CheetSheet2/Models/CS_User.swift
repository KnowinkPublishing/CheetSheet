//
//  CS_User.swift
//  CheetSheet
//
//  Created by Steven Suranie on 4/3/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import Foundation
import RealmSwift

class CS_User: Object {

    @objc dynamic var userID = UUID().uuidString
    @objc dynamic var userName = ""
    @objc dynamic var userEmail = ""
    @objc dynamic var userOrg = ""
    @objc dynamic var userOrgID = ""
    @objc dynamic var userLocation = ""
    @objc dynamic var userZip = ""
    @objc dynamic var userCreateDt = Date()
    @objc dynamic var userUpdateDt = Date()
    @objc dynamic var userLastActiveDt = Date()
    @objc dynamic var userPwd = "NA"
    @objc dynamic var isActive = true
    @objc dynamic var userAvatarPath = ""

}
