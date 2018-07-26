//
//  CS_Topic.swift
//  CheetSheet
//
//  Created by Steven Suranie on 4/8/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import Foundation
import RealmSwift

class CS_Topic: Object {

    @objc dynamic var topicID = UUID().uuidString
    @objc dynamic var topicTitle = ""
    @objc dynamic var topicSubTitle = ""
    @objc dynamic var topicDescription = ""
    @objc dynamic var topicSection = ""
    @objc dynamic var topicCreateDt = Date()
    @objc dynamic var topicUpdateDt = Date()
    @objc dynamic var topicLastActiveDt = Date()
    @objc dynamic var topicHasImages = false

    let topicImagePaths = List<CS_ImagePath>()

}
