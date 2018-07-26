//
//  CS_LOCObj.swift
//  CheetSheet2
//
//  Created by Steven Suranie on 7/11/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import Foundation

struct locObj: Codable {

    let title: String?
    let medium: String?
    let creator: String?
    let created_published_date: String?
    var image: locObjImg

}

struct locObjImg: Codable {

    let alt: String
    let full: String
    let thumb: String

}
