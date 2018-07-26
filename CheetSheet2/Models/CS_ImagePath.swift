//
//  CS_ImagePath.swift
//  CheetSheet
//
//  Created by Steven Suranie on 4/18/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import Foundation
import RealmSwift

class CS_ImagePath: Object {

    @objc dynamic var imageID = UUID().uuidString
    @objc dynamic var imagePHLIdentifier = ""
    @objc dynamic var imagePath = ""
    @objc dynamic var topicID = ""

}
